`timescale 1ns / 1ps

module cacc_requant #(
    parameter PIXEL_NUM    = 8,
    parameter TOTAL_OUT_CH = 16, // 物理阵列并发 16 个输出通道
    parameter ACC_W        = 25,
    parameter BANK_NUM     = 8,
    parameter OBUF_BANK_NUM     = BANK_NUM*2  // 对应 OBUF 16个 Bank
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // CACC Core 交互
    input  wire                               quant_vld,
    input  wire [PIXEL_NUM-1:0]               quant_pixel_mask, // 像素有效掩码
    input  wire [PIXEL_NUM*TOTAL_OUT_CH*ACC_W-1:0] quant_data_in,
    input  wire [15:0]                        quant_co_grp,     // 与 quant_data_in 同 bank 对齐的通道组
    output wire                               requant_ready,

    // CSR 配置接口 (新增)
    input  wire [15:0]                        cfg_out_ch_groups,// 真实的 8 通道组数量！(例如: 8通道传1, 16通道传2, 24通道传3)

    // Prefetcher 1024-bit 参数
    input  wire [1023:0]                      requant_params_1024b,
    input  wire                               cfg_relu_en,   

    // OBUF 写接口 
    input  wire                               obuf_can_write,
    output reg                                obuf_wr_vld,
    output reg  [OBUF_BANK_NUM-1:0]                obuf_wr_mask,     // 16 bit 掩码，分别控制两组 FIFO
    output reg  [OBUF_BANK_NUM*64-1:0]             obuf_wr_dat   
);

    // =========================================================================
    // Stage 1: 并行 DSP 乘加 (P = A * B + C)
    // =========================================================================
    reg p1_vld;
    reg signed [47:0] p1_mult [0:PIXEL_NUM*TOTAL_OUT_CH-1];
    reg [PIXEL_NUM-1:0] p1_mask;
    reg [15:0] p1_mac_co_grp; 
    reg [1023:0] p1_requant_params; // 【新增】：用于缓存量化参数，对齐 Stage 2 流水线

    assign requant_ready = !p1_vld || obuf_can_write;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) p1_vld <= 1'b0;
        else if (start) p1_vld <= 1'b0;
        else if (requant_ready) p1_vld <= quant_vld;
    end

    integer p, ch;
    always @(posedge clk) begin
        if (requant_ready && quant_vld) begin
            p1_mask           <= quant_pixel_mask;
            p1_mac_co_grp     <= quant_co_grp; 
            p1_requant_params <= requant_params_1024b; // 【新增】：将当前周期的参数锁存打一拍
            
            for (p = 0; p < PIXEL_NUM; p = p + 1) begin
                for (ch = 0; ch < TOTAL_OUT_CH; ch = ch + 1) begin
                    // 保持你原有的先乘再累加的切片逻辑不变
                    p1_mult[p*TOTAL_OUT_CH+ch] <= 
                        ( $signed(quant_data_in[(p*TOTAL_OUT_CH+ch)*ACC_W +: ACC_W]) * $signed(requant_params_1024b[ch*64 + 38 +: 18]) ) + 
                        $signed(requant_params_1024b[ch*64 + 0  +: 38]);
                end
            end
        end
    end

    // =========================================================================
    // Stage 2: 移位与饱和截断
    // =========================================================================
    reg                 p2_vld;
    reg [PIXEL_NUM-1:0] p2_mask;
    reg [15:0]          p2_mac_co_grp;
    reg [511:0]         p2_dat_block_g0; 
    reg [511:0]         p2_dat_block_g1; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) p2_vld <= 1'b0;
        else if (start) p2_vld <= 1'b0;
        else if (obuf_can_write) p2_vld <= p1_vld;
    end

    wire signed [7:0] saturated_results [0:PIXEL_NUM*TOTAL_OUT_CH-1];



    genvar gp, gch;
    generate
        for (gp = 0; gp < PIXEL_NUM; gp = gp + 1) begin : P2_PIXEL
            for (gch = 0; gch < TOTAL_OUT_CH; gch = gch + 1) begin : P2_CH
                wire [7:0] shift_val = p1_requant_params[gch*64 + 56 +: 8];
                
                // 确保使用有符号算术右移
                wire signed [47:0] raw = $signed(p1_mult[gp*TOTAL_OUT_CH+gch]) >>> shift_val;
                
                // 【核心修复】：全部使用 48-bit signed 进行比较，杜绝中间截断导致的符号位反转
                wire signed [47:0] min_val = cfg_relu_en ? 48'sd0 : -48'sd128;
                wire signed [47:0] c1      = (raw > 48'sd127) ? 48'sd127 : raw;
                wire signed [47:0] c2      = (c1 < min_val)   ? min_val  : c1;
                
                // 此时 c2 的值已经被死死卡在 [0, 127] 或 [-128, 127] 之间，切片绝对安全
                assign saturated_results[gp*TOTAL_OUT_CH+gch] = c2[7:0];
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (obuf_can_write) begin
            p2_mask       <= p1_mask;
            p2_mac_co_grp <= p1_mac_co_grp;
            
            for (p = 0; p < PIXEL_NUM; p = p + 1) begin
                for (ch = 0; ch < 8; ch = ch + 1) begin
                    p2_dat_block_g0[p*64 + ch*8 +: 8] <= saturated_results[p*TOTAL_OUT_CH + ch];
                end
                for (ch = 8; ch < 16; ch = ch + 1) begin
                    p2_dat_block_g1[p*64 + (ch-8)*8 +: 8] <= saturated_results[p*TOTAL_OUT_CH + ch];
                end
            end
        end
    end

    // =========================================================================
    // Stage 3: OBUF 对齐输出与 **掩码屏蔽判定**
    // =========================================================================
    
    // 动态判断当前 16 个通道中的前 8 个和后 8 个是否真的需要被写入
    // p2_mac_co_grp 乘以 2，相当于转换成了 8 通道组的绝对基地址
    wire grp0_valid = ( {p2_mac_co_grp, 1'b0}          < cfg_out_ch_groups );
    wire grp1_valid = ( {p2_mac_co_grp, 1'b0} + 16'd1  < cfg_out_ch_groups );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) obuf_wr_vld <= 1'b0;
        else if (start) obuf_wr_vld <= 1'b0;
        else            obuf_wr_vld <= p2_vld;
    end

    always @(posedge clk) begin
        // 只有当该通道组真实存在于当前网络层时，才下发像素有效掩码，否则全部置 0，彻底屏蔽写入
        obuf_wr_mask[7:0]  <= grp0_valid ? p2_mask : 8'd0;
        obuf_wr_mask[15:8] <= grp1_valid ? p2_mask : 8'd0;
        
        obuf_wr_dat  <= {p2_dat_block_g1, p2_dat_block_g0};
    end

endmodule
