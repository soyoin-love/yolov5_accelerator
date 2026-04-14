`timescale 1ns / 1ps

module cbuf_dat_top #(
    parameter BANK_NUM   = 8,
    parameter TK_IN      = 8,
    parameter N          = 8,
    parameter ADDR_WIDTH = 10,
    parameter ROW_BLOCKS = 8
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
    input  wire [15:0]                        wr_col_blk,
    input  wire [15:0]                        wr_ch_grp,
    input  wire [BANK_NUM-1:0]                wr_bank_en,
    input  wire [BANK_NUM*TK_IN*N-1:0]        wr_bank_dat,
    input  wire                               wr_row_done,
    output wire                               cbuf_can_write,
    input  wire [7:0]                         rd_en,
    input  wire [15:0]                        rd_row,
    input  wire [15:0]                        rd_col_align,
    input  wire [15:0]                        rd_ch_grp,
    input  wire                               rd_row_free,
    input  wire [3:0]                         rd_free_num,
    output wire                               cbuf_can_read,
    output reg                                rd_dat_vld,
    output reg  [BANK_NUM*TK_IN*N-1:0]        rd_dat_out,
    output wire [15:0]                        status_wr_row_ptr,
    output wire [15:0]                        status_rd_row_ptr
);

    localparam PIXEL_W   = TK_IN * N;
    localparam ROW_SEL_W = (ROW_BLOCKS <= 1) ? 1 : $clog2(ROW_BLOCKS);

    wire [ADDR_WIDTH-1:0] block_size;
    wire [ROW_SEL_W-1:0]  wr_row_slot;
    wire [ROW_SEL_W-1:0]  rd_row_slot;

    reg  [15:0] wr_row_ptr;
    reg  [15:0] rd_row_ptr;

    reg  [ADDR_WIDTH-1:0] wr_mul_row_t1;
    reg  [ADDR_WIDTH-1:0] wr_mul_ch_t1;
    reg  [ADDR_WIDTH-1:0] wr_offset_t1;
    reg                   wr_en_t1;
    reg  [BANK_NUM-1:0]   wr_bank_en_t1;
    reg  [BANK_NUM*PIXEL_W-1:0] wr_bank_dat_t1;

    reg  [ADDR_WIDTH-1:0] rd_mul_row_t1;
    reg  [ADDR_WIDTH-1:0] rd_mul_ch_t1;
    // 读列基址需要按有符号数处理，否则左侧 padding 时会把负列号误当成大正数地址。
    reg signed [ADDR_WIDTH:0] rd_offset_base_t1;
    reg  [2:0]            rd_align_offset_t1;
    reg  [7:0]            rd_en_t1;

    reg signed [ADDR_WIDTH:0] base_rd_addr_t2;
    reg  [2:0]            rd_align_offset_t2;
    reg  [7:0]            rd_en_t2;

    reg  [2:0]            rd_align_offset_t3;
    reg  [BANK_NUM-1:0]   bank_rd_vld_t3;
    reg  [BANK_NUM*PIXEL_W-1:0] shifted_dat;

    wire [15:0]           valid_rows;
    wire [ADDR_WIDTH-1:0] wr_addr_t1;
    wire [BANK_NUM-1:0]   bank_wr_en_w;
    wire [BANK_NUM*PIXEL_W-1:0] raw_rd_dat;

    integer i;

    assign block_size  = cfg_max_col_blocks * cfg_max_ch_groups;
    assign wr_row_slot = wr_row[ROW_SEL_W-1:0];
    assign rd_row_slot = rd_row[ROW_SEL_W-1:0];
    assign valid_rows  = wr_row_ptr - rd_row_ptr;
    assign wr_addr_t1  = wr_mul_row_t1 + wr_mul_ch_t1 + wr_offset_t1;

    assign cbuf_can_write = (valid_rows < ROW_BLOCKS);
    assign cbuf_can_read  = (valid_rows >= cfg_min_calc_rows) ||
                            ((wr_row_ptr >= cfg_height) && (valid_rows > 0));
    // 对外导出当前环形缓冲区的逻辑写/读行指针，便于上层在多读端场景下做精确行窗口判断。
    assign status_wr_row_ptr = wr_row_ptr;
    assign status_rd_row_ptr = rd_row_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_row_ptr <= 16'd0;
            rd_row_ptr <= 16'd0;
        end else begin
            if (wr_row_done) begin
                wr_row_ptr <= wr_row_ptr + 16'd1;
            end
            if (rd_row_free) begin
                rd_row_ptr <= rd_row_ptr + rd_free_num;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_mul_row_t1  <= {ADDR_WIDTH{1'b0}};
            wr_mul_ch_t1   <= {ADDR_WIDTH{1'b0}};
            wr_offset_t1   <= {ADDR_WIDTH{1'b0}};
            wr_en_t1       <= 1'b0;
            wr_bank_en_t1  <= {BANK_NUM{1'b0}};
            wr_bank_dat_t1 <= {(BANK_NUM*PIXEL_W){1'b0}};
        end else begin
            wr_mul_row_t1  <= wr_row_slot * block_size;
            wr_mul_ch_t1   <= wr_ch_grp[ADDR_WIDTH-1:0] * cfg_max_col_blocks;
            wr_offset_t1   <= wr_col_blk[ADDR_WIDTH-1:0];
            wr_en_t1       <= wr_en;
            wr_bank_en_t1  <= wr_bank_en;
            wr_bank_dat_t1 <= wr_bank_dat;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_mul_row_t1      <= {ADDR_WIDTH{1'b0}};
            rd_mul_ch_t1       <= {ADDR_WIDTH{1'b0}};
            rd_offset_base_t1  <= {(ADDR_WIDTH+1){1'b0}};
            rd_align_offset_t1 <= 3'd0;
            rd_en_t1           <= 8'd0;
        end else begin
            rd_mul_row_t1      <= rd_row_slot * block_size;
            rd_mul_ch_t1       <= rd_ch_grp[ADDR_WIDTH-1:0] * cfg_max_col_blocks;
            // 这里必须做算术右移。
            // 例如 rd_col_align = -2 时，列块基址应为 -1，低 3bit 对齐偏移为 6。
            // 这样后面的 bank 地址重排才能得到：
            //   [-2,-1,0,1,2,3,4,5] -> 仅有效读取 [0,1,2,3,4,5]
            rd_offset_base_t1  <= $signed(rd_col_align) >>> 3;
            rd_align_offset_t1 <= rd_col_align[2:0];

            rd_en_t1[0] <= rd_en[(0 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[1] <= rd_en[(1 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[2] <= rd_en[(2 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[3] <= rd_en[(3 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[4] <= rd_en[(4 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[5] <= rd_en[(5 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[6] <= rd_en[(6 - rd_col_align[2:0]) & 3'b111];
            rd_en_t1[7] <= rd_en[(7 - rd_col_align[2:0]) & 3'b111];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            base_rd_addr_t2    <= {(ADDR_WIDTH+1){1'b0}};
            rd_align_offset_t2 <= 3'd0;
            rd_en_t2           <= 8'd0;
        end else begin
            base_rd_addr_t2    <= $signed({1'b0, rd_mul_row_t1}) +
                                  $signed({1'b0, rd_mul_ch_t1}) +
                                  rd_offset_base_t1;
            rd_align_offset_t2 <= rd_align_offset_t1;
            rd_en_t2           <= rd_en_t1;
        end
    end

    genvar b;
    generate
        for (b = 0; b < BANK_NUM; b = b + 1) begin : BANK_INST
            wire [PIXEL_W-1:0] bank_wr_dat_w;
            wire [ADDR_WIDTH-1:0] bank_rd_addr_w;
            wire signed [ADDR_WIDTH:0] bank_rd_addr_s_w;
            wire bank_rd_addr_valid_w;

            assign bank_wr_en_w[b] = wr_en_t1 && wr_bank_en_t1[b];
            assign bank_wr_dat_w   = wr_bank_dat_t1[b*PIXEL_W +: PIXEL_W];
            // 左侧 padding 时，base_rd_addr_t2 可能为负。
            // 此时只允许有效 bank 去访问非负地址；无效 bank 直接关掉读使能。
            assign bank_rd_addr_s_w =
                base_rd_addr_t2 +
                ((b < rd_align_offset_t2) ? $signed({{ADDR_WIDTH{1'b0}}, 1'b1})
                                          : $signed({(ADDR_WIDTH+1){1'b0}}));
            assign bank_rd_addr_valid_w = ~bank_rd_addr_s_w[ADDR_WIDTH];
            assign bank_rd_addr_w =
                bank_rd_addr_valid_w ? bank_rd_addr_s_w[ADDR_WIDTH-1:0]
                                     : {ADDR_WIDTH{1'b0}};

            cbuf u_buf (
                .clka  (clk),
                .ena   (1'b1),
                .wea   (bank_wr_en_w[b]),
                .addra (wr_addr_t1),
                .dina  (bank_wr_dat_w),
                .clkb  (clk),
                .enb   (rd_en_t2[b] && bank_rd_addr_valid_w),
                .addrb (bank_rd_addr_w),
                .doutb (raw_rd_dat[b*PIXEL_W +: PIXEL_W])
            );
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_align_offset_t3 <= 3'd0;
            bank_rd_vld_t3     <= {BANK_NUM{1'b0}};
        end else begin
            rd_align_offset_t3 <= rd_align_offset_t2;
            bank_rd_vld_t3     <= rd_en_t2;
        end
    end

    always @(*) begin
        shifted_dat = {(BANK_NUM*PIXEL_W){1'b0}};
        for (i = 0; i < BANK_NUM; i = i + 1) begin
            shifted_dat[i*PIXEL_W +: PIXEL_W] =
                raw_rd_dat[((i + rd_align_offset_t3) & 3'b111) * PIXEL_W +: PIXEL_W];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_dat_out <= {(BANK_NUM*PIXEL_W){1'b0}};
            rd_dat_vld <= 1'b0;
        end else begin
            rd_dat_out <= shifted_dat;
            rd_dat_vld <= |bank_rd_vld_t3;
        end
    end

endmodule
