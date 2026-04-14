`timescale 1ns / 1ps

// 64bit:[37:0]偏置   [55:38]缩放系数  [63:56]移位值  
module bbuf_prefetcher #(
    parameter BANK_NUM   = 8,
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 9
)(
    input  wire                    clk,
    input  wire                    rst_n,

    // ==========================================
    // 新增：CSR 参数
    // ==========================================
    input  wire [15:0]             cfg_b_total_beats, // 该层偏置总的 AXI 节拍数

    // ==========================================
    // 监听 CACC 实际接收状态
    // ==========================================
    input  wire                    mac_accept_last_ci,
    input  wire [15:0]             mac_accept_co_grp,

    // ==========================================
    // 驱动 BBUF 读接口
    // ==========================================
    output wire [BANK_NUM-1:0]     bbuf_rd_en,
    output wire [ADDR_WIDTH-1:0]   bbuf_rd_addr,
    input  wire [BANK_NUM*DATA_WIDTH-1:0]  bbuf_rd_dat,

    // ==========================================
    // 输出给 CACC Requant
    // ==========================================
    output wire [1023:0]           requant_params_1024b 
);

    // 发令枪逻辑
    wire trigger_t0 = mac_accept_last_ci;
    reg        trigger_t1;
    reg [15:0] latched_co_grp_t1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trigger_t1        <= 1'b0;
            latched_co_grp_t1 <= 16'd0;
        end else begin
            trigger_t1 <= trigger_t0;
            if (trigger_t0) latched_co_grp_t1 <= mac_accept_co_grp;
        end
    end

    // =======================================================
    // 动态掩码生成逻辑 (Dynamic Mask Generation)
    // =======================================================
    //一个输出通道组占2个BBUF地址
    wire [ADDR_WIDTH-1:0] current_addr = trigger_t0 ? 
                                        (mac_accept_co_grp[ADDR_WIDTH-2:0] << 1) : 
                                        ((latched_co_grp_t1[ADDR_WIDTH-2:0] << 1) + 1'b1);

    assign bbuf_rd_addr = current_addr;

    // 1 个 BBUF 地址包含 4 个 AXI Beats (8 个通道)
    wire [15:0] start_beat = current_addr << 2; 
    reg  [7:0]  rd_mask;

    always @(*) begin
        if (cfg_b_total_beats <= start_beat) begin
            // 场景 1：当前地址已经超出了有效节拍范围，全关
            rd_mask = 8'b0000_0000;
        end else if (cfg_b_total_beats >= start_beat + 4) begin
            // 场景 2：当前地址被有效节拍完全覆盖，全开
            rd_mask = 8'b1111_1111;
        end else begin
            // 场景 3：处于边界地址，部分 Bank 有效
            case (cfg_b_total_beats - start_beat)
                16'd1: rd_mask = 8'b0000_0011; // 仅 1 拍有效 (通道 0, 1)
                16'd2: rd_mask = 8'b0000_1111; // 仅 2 拍有效 (通道 0~3)
                16'd3: rd_mask = 8'b0011_1111; // 仅 3 拍有效 (通道 0~5)
                default: rd_mask = 8'b0000_0000;
            endcase
        end
    end

    // 使能端：仅在 T0 或 T1 拉高对应的有效掩码
    assign bbuf_rd_en = (trigger_t0 || trigger_t1) ? rd_mask : 8'd0;

    // =======================================================
    // 读数据清洗逻辑 (Data Cleaning Pipeline)
    // =======================================================
    // 由于 RAM 数据在一拍后吐出，掩码也必须同步打一拍
    reg [7:0] rd_mask_d1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_mask_d1 <= 8'd0;
        end else if (trigger_t0 || trigger_t1) begin
            rd_mask_d1 <= rd_mask;
        end else begin
            rd_mask_d1 <= 8'd0;
        end
    end

    wire [BANK_NUM*DATA_WIDTH-1:0] clean_bbuf_rd_dat;
    
    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : CLEAN_DAT
            // 硬件级短路：无效通道强制置为 64'd0
            assign clean_bbuf_rd_dat[b*DATA_WIDTH +: DATA_WIDTH] = 
                rd_mask_d1[b] ? bbuf_rd_dat[b*DATA_WIDTH +: DATA_WIDTH] : {DATA_WIDTH{1'b0}};
        end
    endgenerate

    // =======================================================
    // 1024-bit 拼装 (T1 锁存，T2 拼装)
    // =======================================================
    reg [BANK_NUM*DATA_WIDTH-1:0] bbuf_dat_low_reg;
    always @(posedge clk) begin
        if (trigger_t1) bbuf_dat_low_reg <= clean_bbuf_rd_dat; // 存下洗干净的低 8 通道
    end

    // 拼装 1024-bit 给量化模块：
    // 此时 clean_bbuf_rd_dat 吐出的是高 8 通道
    assign requant_params_1024b = {clean_bbuf_rd_dat, bbuf_dat_low_reg};

endmodule
