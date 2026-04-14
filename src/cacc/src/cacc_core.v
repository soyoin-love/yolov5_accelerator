`timescale 1ns / 1ps

module cacc_core #(
    parameter PIXEL_NUM  = 8,   // 并行处理的像素个数 (N=8)
    parameter OUT_CH_NUM = 16,  // 并行处理的输出通道数 (TK_OUT=16)
    parameter PSUM_W     = 19,
    parameter ACC_W      = 27,
    parameter BANK_CNT   = 4    // 采用 4-bank 环形结构，保证 1x1 场景也能持续吞吐
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // MAC 阵列输入
    input  wire                               mac_valid,
    input  wire [7:0]                         mac_pixel_mask,
    input  wire                               mac_is_last_ci,
    input  wire [15:0]                        mac_co_grp,
    input  wire [PIXEL_NUM*OUT_CH_NUM*PSUM_W-1:0] psum_in,

    // 握手与反压
    input  wire                               requant_ready,
    output wire                               cacc_ready,

    // 输出接口 (发往量化模块)
    output reg                                quant_vld,
    output reg  [7:0]                         quant_pixel_mask,
    output reg  [15:0]                        quant_co_grp,
    output wire [PIXEL_NUM*OUT_CH_NUM*ACC_W-1:0]  quant_data_in
);
    localparam BANK_IDX_W = (BANK_CNT <= 2) ? 1 : $clog2(BANK_CNT);

    // 多 bank 环形累加存储。
    // 当前 wr_bank 负责接收正在累加的输出块；rd_bank 指向最老的待量化块。
    reg signed [ACC_W-1:0] acc_mem [0:BANK_CNT-1][0:PIXEL_NUM-1][0:OUT_CH_NUM-1];
    reg [BANK_IDX_W-1:0] wr_bank;
    reg [BANK_IDX_W-1:0] rd_bank;
    reg                  is_first_ci;
    reg [BANK_CNT-1:0]   bank_full;

    reg [7:0]            meta_mask   [0:BANK_CNT-1];
    reg [15:0]           meta_co_grp [0:BANK_CNT-1];

    wire input_accept = mac_valid && cacc_ready;
    wire pop_quant    = quant_vld && requant_ready;

    function automatic [BANK_IDX_W-1:0] next_bank_idx;
        input [BANK_IDX_W-1:0] cur_bank;
        begin
            if (cur_bank == BANK_CNT - 1)
                next_bank_idx = {BANK_IDX_W{1'b0}};
            else
                next_bank_idx = cur_bank + {{(BANK_IDX_W-1){1'b0}}, 1'b1};
        end
    endfunction

    wire [BANK_IDX_W-1:0] wr_bank_next_w = next_bank_idx(wr_bank);
    wire [BANK_IDX_W-1:0] rd_bank_next_w = next_bank_idx(rd_bank);

    assign cacc_ready = ~bank_full[wr_bank];

    // Bank 状态机：
    // 1. 输入最后一拍到来时，当前写 bank 标记为 full，并切换到下一个空 bank。
    // 2. 量化侧真正接收时，当前读 bank 被释放，并读指针推进。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_bank     <= {BANK_IDX_W{1'b0}};
            rd_bank     <= {BANK_IDX_W{1'b0}};
            is_first_ci <= 1'b1;
            bank_full   <= {BANK_CNT{1'b0}};
        end else if (start) begin
            wr_bank     <= {BANK_IDX_W{1'b0}};
            rd_bank     <= {BANK_IDX_W{1'b0}};
            is_first_ci <= 1'b1;
            bank_full   <= {BANK_CNT{1'b0}};
        end else begin
            if (pop_quant) begin
                bank_full[rd_bank] <= 1'b0;
                rd_bank            <= rd_bank_next_w;
            end

            if (input_accept) begin
                is_first_ci <= mac_is_last_ci;
                if (mac_is_last_ci) begin
                    bank_full[wr_bank] <= 1'b1;
                    wr_bank            <= wr_bank_next_w;
                end
            end
        end
    end

    // 累加数据与 metadata 写入。
    // 新输出块的第一拍直接覆盖旧值；后续拍执行加法累加。
    integer p, ch;
    always @(posedge clk) begin
        if (input_accept) begin
            if (is_first_ci) begin
                meta_mask[wr_bank]   <= mac_pixel_mask;
                meta_co_grp[wr_bank] <= mac_co_grp;
            end

            for (p = 0; p < PIXEL_NUM; p = p + 1) begin
                for (ch = 0; ch < OUT_CH_NUM; ch = ch + 1) begin
                    if (is_first_ci)
                        acc_mem[wr_bank][p][ch] <= $signed(psum_in[(p*OUT_CH_NUM+ch)*PSUM_W +: PSUM_W]);
                    else
                        acc_mem[wr_bank][p][ch] <= acc_mem[wr_bank][p][ch] +
                                                   $signed(psum_in[(p*OUT_CH_NUM+ch)*PSUM_W +: PSUM_W]);
                end
            end
        end
    end

    // 量化请求控制。
    // 这里特别处理“连续满 bank”场景：当本拍 pop 掉当前 bank 后，如果下一个 bank 也已满，
    // 则 quant_vld 下一拍继续保持高电平，消除 2-bank 结构中的气泡。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quant_vld        <= 1'b0;
            quant_pixel_mask <= 8'd0;
            quant_co_grp     <= 16'd0;
        end else if (start) begin
            quant_vld        <= 1'b0;
            quant_pixel_mask <= 8'd0;
            quant_co_grp     <= 16'd0;
        end else begin
            if (pop_quant) begin
                if (bank_full[rd_bank_next_w]) begin
                    quant_vld        <= 1'b1;
                    quant_pixel_mask <= meta_mask[rd_bank_next_w];
                    quant_co_grp     <= meta_co_grp[rd_bank_next_w];
                end else begin
                    quant_vld        <= 1'b0;
                    quant_pixel_mask <= 8'd0;
                    quant_co_grp     <= 16'd0;
                end
            end else if (!quant_vld && bank_full[rd_bank]) begin
                quant_vld        <= 1'b1;
                quant_pixel_mask <= meta_mask[rd_bank];
                quant_co_grp     <= meta_co_grp[rd_bank];
            end
        end
    end

    // 量化数据始终从当前读 bank 取出。
    genvar gp, gch;
    generate
        for (gp = 0; gp < PIXEL_NUM; gp = gp + 1) begin : OUT_P
            for (gch = 0; gch < OUT_CH_NUM; gch = gch + 1) begin : OUT_CH
                assign quant_data_in[(gp*OUT_CH_NUM+gch)*ACC_W +: ACC_W] =
                    acc_mem[rd_bank][gp][gch];
            end
        end
    endgenerate

endmodule
