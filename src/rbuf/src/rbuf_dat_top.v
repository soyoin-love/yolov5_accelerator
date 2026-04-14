`timescale 1ns / 1ps

// 残差输入专用行缓存。
// 当前版本使用双端口 RAM：
// 1. A 口只写，B 口只读，天然支持并行读写；
// 2. 用户确认当前 rbuf IP 的 B 口从 enb/addrb 到 doutb 为 1 拍延迟；
// 3. 外围仅保留必要的地址/控制打拍，避免再沿用旧单口 RAM 版本的冗长对齐链。
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
    output wire [BANK_NUM*TK_IN*N-1:0]        rd_dat_out,
    output wire [15:0]                        status_wr_row_ptr,
    output wire [15:0]                        status_rd_row_ptr
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

    reg [7:0]            rd_mask_t3;
    reg                  rd_req_vld_t3;
    reg [BANK_NUM*PIXEL_W-1:0] rd_dat_out_r;

    wire [ADDR_WIDTH-1:0] block_size;
    wire [15:0]           valid_rows;
    wire [ADDR_WIDTH-1:0] wr_addr_t1;

    wire [BANK_NUM-1:0]         bank_wr_en;
    wire [BANK_NUM-1:0]         bank_rd_en;
    wire [BANK_NUM*PIXEL_W-1:0] bank_rd_dat;
    wire [BANK_NUM*PIXEL_W-1:0] rd_dat_masked_t3;

    genvar g;
    genvar b;

    assign block_size   = cfg_max_col_blocks * cfg_max_ch_groups;
    assign valid_rows   = wr_row_ptr - rd_row_ptr;
    assign wr_addr_t1   = wr_row_base_t1 + wr_ch_base_t1 + wr_col_base_t1;

    // 双端口版本不再做读写互斥，允许写端和读端独立工作。
    assign rbuf_can_write = (valid_rows < ROW_BLOCKS);
    assign rbuf_can_read  = ((valid_rows >= cfg_min_calc_rows) ||
                            ((wr_row_ptr >= cfg_height) && (valid_rows > 0)));

    assign status_wr_row_ptr = wr_row_ptr;
    assign status_rd_row_ptr = rd_row_ptr;
    assign rd_dat_out        = rd_dat_out_r;

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

    // 写路径第 1 拍：把写入位置与 bank 选择打一拍，缩短进入 RAM 的组合路径。
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

    // 读路径第 1 拍：先寄存部分地址与读 mask。
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
                rd_en_t1       <= 8'd0;
                rd_req_vld_t1  <= 1'b0;
            end
        end
    end

    // 读路径第 2 拍：形成最终 B 口地址并送入双端口 RAM。
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

    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : RBUF_BANKS
            wire [PIXEL_W-1:0]   bank_wr_dat;
            wire [ADDR_WIDTH-1:0] bank_wr_addr;
            wire [ADDR_WIDTH-1:0] bank_rd_addr;
            wire                  bank_wena;
            wire                  bank_renb;
            wire [0:0]            bank_we;

            assign bank_wr_en[b] = wr_en_t1 &&
                                   ((b == wr_bank0_t1) || (b == wr_bank1_t1));
            assign bank_rd_en[b] = rd_req_vld_t2 && rd_en_t2[b];

            assign bank_wr_dat = (b == wr_bank0_t1) ? wr_dat_t1[PIXEL_W-1:0] :
                                 (b == wr_bank1_t1) ? wr_dat_t1[2*PIXEL_W-1:PIXEL_W] :
                                                      {PIXEL_W{1'b0}};
            assign bank_wr_addr = wr_addr_t1;
            assign bank_rd_addr = rd_addr_t2;
            assign bank_wena    = bank_wr_en[b];
            assign bank_renb    = bank_rd_en[b];
            assign bank_we[0]   = bank_wr_en[b];

            rbuf u_bank (
                .clka  (clk),
                .ena   (bank_wena),
                .wea   (bank_we),
                .addra (bank_wr_addr),
                .dina  (bank_wr_dat),
                .clkb  (clk),
                .enb   (bank_renb),
                .addrb (bank_rd_addr),
                .doutb (bank_rd_dat[b*PIXEL_W +: PIXEL_W])
            );
        end
    endgenerate

    // 读路径第 3 拍：B 口一拍返回后，再对齐 mask/valid。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_mask_t3    <= 8'd0;
            rd_req_vld_t3 <= 1'b0;
        end else begin
            rd_mask_t3    <= rd_en_t2;
            rd_req_vld_t3 <= rd_req_vld_t2;
        end
    end

    generate
        for (g = 0; g < BANK_NUM; g = g + 1) begin : GEN_RD_MASK
            assign rd_dat_masked_t3[g*PIXEL_W +: PIXEL_W] =
                rd_mask_t3[g] ? bank_rd_dat[g*PIXEL_W +: PIXEL_W] : {PIXEL_W{1'b0}};
        end
    endgenerate

    // 对外输出稳定数据与握手。
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rd_dat_out_r <= {(BANK_NUM*PIXEL_W){1'b0}};
            rd_dat_vld   <= 1'b0;
        end else begin
            if (rd_req_vld_t3) begin
                rd_dat_out_r <= rd_dat_masked_t3;
            end
            rd_dat_vld <= rd_req_vld_t3;
        end
    end

endmodule
