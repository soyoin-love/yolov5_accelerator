`timescale 1ns / 1ps

// 残差输入专用行缓存。
// 底层由 8 个单端口 rbuf IP 组成，每个 bank 存 1 个像素的 8 通道数据。
// 这里把读路径拆成 3 拍：
// 1. 先计算行槽位、通道组和列块的部分地址；
// 2. 再做一次加法，形成最终 SRAM 地址；
// 3. 由单端口 SRAM 返回数据，并拉高 rd_dat_vld。
// 因此从 rd_en 拉高到 rd_dat_vld 拉高固定为 3 个时钟周期。
module rbuf_dat_top #(
    parameter BANK_NUM   = 8,
    parameter TK_IN      = 8,
    parameter N          = 8,
    parameter ADDR_WIDTH = 9,
    parameter ROW_BLOCKS = 2
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    input  wire [ADDR_WIDTH-1:0]              cfg_max_col_blocks,
    input  wire [ADDR_WIDTH-1:0]              cfg_max_ch_groups,
    input  wire [3:0]                         cfg_min_calc_rows,
    input  wire [15:0]                        cfg_height,

    input  wire                               wr_en,
    input  wire [15:0]                        wr_row,
    input  wire [15:0]                        wr_col,
    input  wire [15:0]                        wr_ch_grp,
    input  wire [2*TK_IN*N-1:0]               wr_dat,
    input  wire                               wr_pending,
    input  wire                               wr_row_done,
    output wire                               rbuf_can_write,

    input  wire [7:0]                         rd_en,
    input  wire [15:0]                        rd_row,
    input  wire [15:0]                        rd_col_align,
    input  wire [15:0]                        rd_ch_grp,
    input  wire                               rd_row_free,
    input  wire [3:0]                         rd_free_num,
    output wire                               rbuf_can_read,
    output reg                                rd_dat_vld,
    output wire [BANK_NUM*TK_IN*N-1:0]        rd_dat_out
);

    localparam PIXEL_W = TK_IN * N;

    reg [15:0] wr_row_ptr;
    reg [15:0] rd_row_ptr;

    reg [ADDR_WIDTH-1:0] wr_row_base_t1;
    reg [ADDR_WIDTH-1:0] wr_ch_base_t1;
    reg [ADDR_WIDTH-1:0] wr_col_base_t1;
    reg [2*TK_IN*N-1:0]  wr_dat_t1;
    reg [2:0]            wr_bank0_t1;
    reg [2:0]            wr_bank1_t1;
    reg                  wr_en_t1;
    reg                  wr_row_done_t1;

    reg [ADDR_WIDTH-1:0] rd_row_base_t1;
    reg [ADDR_WIDTH-1:0] rd_ch_base_t1;
    reg [ADDR_WIDTH-1:0] rd_col_base_t1;
    reg [7:0]            rd_en_t1;
    reg                  rd_req_vld_t1;

    reg [ADDR_WIDTH-1:0] rd_addr_t2;
    reg [7:0]            rd_en_t2;
    reg                  rd_req_vld_t2;

    reg [7:0]            rd_en_t3;
    reg [BANK_NUM*PIXEL_W-1:0] rd_dat_masked;

    wire [ADDR_WIDTH-1:0] block_size;
    wire [15:0]           valid_rows;
    wire                  wr_pipe_busy;
    wire                  rd_pipe_busy;
    wire [ADDR_WIDTH-1:0] wr_addr_t1;

    wire [BANK_NUM-1:0]         bank_wr_en;
    wire [BANK_NUM-1:0]         bank_rd_en;
    wire [BANK_NUM*PIXEL_W-1:0] bank_rd_dat;

    integer i;

    assign block_size  = cfg_max_col_blocks * cfg_max_ch_groups;
    assign valid_rows  = wr_row_ptr - rd_row_ptr;
    assign wr_pipe_busy = wr_en | wr_pending | wr_en_t1;
    assign rd_pipe_busy = (|rd_en) | rd_req_vld_t1 | rd_req_vld_t2;
    assign wr_addr_t1  = wr_row_base_t1 + wr_ch_base_t1 + wr_col_base_t1;

    // 单端口 SRAM 不能在同一拍同时接收新的读地址和写地址。
    // 这里在 wrapper 层做互斥，保证读写路径干净，减轻地址路径压力。
    assign rbuf_can_write = (valid_rows < ROW_BLOCKS) && !rd_pipe_busy;
    assign rbuf_can_read  = (((valid_rows >= cfg_min_calc_rows) ||
                            ((wr_row_ptr >= cfg_height) && (valid_rows > 0))) &&
                            !wr_pipe_busy);

    assign rd_dat_out = rd_dat_masked;

    // 环形行指针。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_row_ptr <= 16'd0;
            rd_row_ptr <= 16'd0;
        end else begin
            if (wr_row_done_t1) begin
                wr_row_ptr <= wr_row_ptr + 1'b1;
            end
            if (rd_row_free) begin
                rd_row_ptr <= rd_row_ptr + rd_free_num;
            end
        end
    end

    // 写路径第 1 拍：提前完成行槽位、通道组和列块地址计算。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_row_base_t1 <= {ADDR_WIDTH{1'b0}};
            wr_ch_base_t1  <= {ADDR_WIDTH{1'b0}};
            wr_col_base_t1 <= {ADDR_WIDTH{1'b0}};
            wr_dat_t1      <= {(2*TK_IN*N){1'b0}};
            wr_bank0_t1    <= 3'd0;
            wr_bank1_t1    <= 3'd0;
            wr_en_t1       <= 1'b0;
            wr_row_done_t1 <= 1'b0;
        end else begin
            wr_row_base_t1 <= (wr_row % ROW_BLOCKS) * block_size;
            wr_ch_base_t1  <= wr_ch_grp[ADDR_WIDTH-1:0] * cfg_max_col_blocks;
            wr_col_base_t1 <= wr_col[ADDR_WIDTH-1:0] >> 3;
            wr_dat_t1      <= wr_dat;
            wr_bank0_t1    <= wr_col[2:0];
            wr_bank1_t1    <= wr_col[2:0] + 1'b1;
            wr_en_t1       <= wr_en;
            wr_row_done_t1 <= wr_row_done;
        end
    end

    // 读路径第 1 拍：先把乘法和移位拆开。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_row_base_t1 <= {ADDR_WIDTH{1'b0}};
            rd_ch_base_t1  <= {ADDR_WIDTH{1'b0}};
            rd_col_base_t1 <= {ADDR_WIDTH{1'b0}};
            rd_en_t1       <= 8'd0;
            rd_req_vld_t1  <= 1'b0;
        end else begin
            if ((|rd_en) && rbuf_can_read) begin
                rd_row_base_t1 <= (rd_row % ROW_BLOCKS) * block_size;
                rd_ch_base_t1  <= rd_ch_grp[ADDR_WIDTH-1:0] * cfg_max_col_blocks;
                rd_col_base_t1 <= rd_col_align[ADDR_WIDTH-1:0] >> 3;
                rd_en_t1       <= rd_en;
                rd_req_vld_t1  <= 1'b1;
            end else begin
                rd_en_t1      <= 8'd0;
                rd_req_vld_t1 <= 1'b0;
            end
        end
    end

    // 读路径第 2 拍：完成最终地址加法。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_addr_t2    <= {ADDR_WIDTH{1'b0}};
            rd_en_t2      <= 8'd0;
            rd_req_vld_t2 <= 1'b0;
        end else begin
            rd_addr_t2    <= rd_row_base_t1 + rd_ch_base_t1 + rd_col_base_t1;
            rd_en_t2      <= rd_en_t1;
            rd_req_vld_t2 <= rd_req_vld_t1;
        end
    end

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : RBUF_BANKS
            wire [PIXEL_W-1:0] bank_wr_dat;
            wire [ADDR_WIDTH-1:0] bank_addr;
            wire bank_ena;
            wire [0:0] bank_we;

            assign bank_wr_en[b] = wr_en_t1 &&
                                ((b == wr_bank0_t1) || (b == wr_bank1_t1));
            assign bank_rd_en[b] = rd_req_vld_t2 && rd_en_t2[b];

            assign bank_wr_dat = ((b == wr_bank0_t1) ? wr_dat_t1[PIXEL_W-1:0] :
                                ((b == wr_bank1_t1) ? wr_dat_t1[2*PIXEL_W-1:PIXEL_W] :
                                {PIXEL_W{1'b0}}));
            assign bank_addr = wr_en_t1 ? wr_addr_t1 : rd_addr_t2;
            assign bank_ena  = bank_wr_en[b] | bank_rd_en[b];
            assign bank_we[0] = bank_wr_en[b];

            rbuf u_bank (
                .clka  (clk),
                .ena   (bank_ena),
                .wea   (bank_we),
                .addra (bank_addr),
                .dina  (bank_wr_dat),
                .douta (bank_rd_dat[b*PIXEL_W +: PIXEL_W])
            );
        end
    endgenerate

    // 读路径第 3 拍：SRAM 返回数据，并对无效 bank 做清零。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_en_t3   <= 8'd0;
            rd_dat_vld <= 1'b0;
        end else begin
            rd_en_t3   <= rd_en_t2;
            rd_dat_vld <= rd_req_vld_t2;
        end
    end

    always @(*) begin
        rd_dat_masked = {(BANK_NUM*PIXEL_W){1'b0}};

        for (i = 0; i < BANK_NUM; i = i + 1) begin
            if (rd_en_t3[i]) begin
                rd_dat_masked[i*PIXEL_W +: PIXEL_W] = bank_rd_dat[i*PIXEL_W +: PIXEL_W];
            end
        end
    end

endmodule
