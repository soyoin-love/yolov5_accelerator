`timescale 1ns / 1ps

module cdma_top_cat #(
    parameter ROW_BLOCKS = 8,
    parameter BANK_NUM   = 8,
    parameter TK_IN      = 8,
    parameter N          = 8
)(
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire                        start,

    input  wire [31:0]                 cfg_base_addr,
    input  wire [15:0]                 cfg_width,
    input  wire [15:0]                 cfg_height,
    input  wire [15:0]                 cfg_ch_groups,
    input  wire                        cfg_cat_en,
    input  wire                        cfg_cat_src0_upsample,
    input  wire [31:0]                 cfg_cat_src1_base_addr,
    input  wire [15:0]                 cfg_cat_src0_ch_groups,
    input  wire [31:0]                 cfg_cat_src0_line_stride,
    input  wire [31:0]                 cfg_cat_src1_line_stride,
    input  wire [31:0]                 cfg_cat_src0_surface_stride,
    input  wire [31:0]                 cfg_cat_src1_surface_stride,

    input  wire                        rd_row_free,
    input  wire [3:0]                  rd_free_num,

    input  wire                        mcif_req_rdy,
    output wire                        mcif_req_vld,
    output wire [39:0]                 mcif_req_pd,

    input  wire                        mcif_rx_vld,
    input  wire [2*TK_IN*N-1:0]        mcif_rx_dat,
    output wire                        mcif_rx_rdy,

    output wire                        wr_en,
    output wire [15:0]                 wr_row,
    output wire [15:0]                 wr_col_blk,
    output wire [15:0]                 wr_ch_grp,
    output wire [BANK_NUM-1:0]         wr_bank_en,
    output wire [BANK_NUM*TK_IN*N-1:0] wr_bank_dat,
    output wire                        wr_row_done
);

    cdma_read_req_cat #(
        .ROW_BLOCKS(ROW_BLOCKS)
    ) u_cdma_read_req (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .start                      (start),
        .cfg_base_addr              (cfg_base_addr),
        .cfg_width                  (cfg_width),
        .cfg_height                 (cfg_height),
        .cfg_ch_groups              (cfg_ch_groups),
        .cfg_cat_en                 (cfg_cat_en),
        .cfg_cat_src0_upsample      (cfg_cat_src0_upsample),
        .cfg_cat_src1_base_addr     (cfg_cat_src1_base_addr),
        .cfg_cat_src0_ch_groups     (cfg_cat_src0_ch_groups),
        .cfg_cat_src0_line_stride   (cfg_cat_src0_line_stride),
        .cfg_cat_src1_line_stride   (cfg_cat_src1_line_stride),
        .cfg_cat_src0_surface_stride(cfg_cat_src0_surface_stride),
        .cfg_cat_src1_surface_stride(cfg_cat_src1_surface_stride),
        .rd_row_free                (rd_row_free),
        .rd_free_num                (rd_free_num),
        .mcif_req_rdy               (mcif_req_rdy),
        .mcif_req_vld               (mcif_req_vld),
        .mcif_req_pd                (mcif_req_pd)
    );

    cdma_rx_write_cat #(
        .BANK_NUM(BANK_NUM),
        .TK_IN   (TK_IN),
        .N       (N)
    ) u_cdma_rx_write (
        .clk                  (clk),
        .rst_n                (rst_n),
        .start                (start),
        .cfg_width            (cfg_width),
        .cfg_height           (cfg_height),
        .cfg_ch_groups        (cfg_ch_groups),
        .cfg_cat_en           (cfg_cat_en),
        .cfg_cat_src0_upsample(cfg_cat_src0_upsample),
        .cfg_cat_src0_ch_groups(cfg_cat_src0_ch_groups),
        .mcif_rx_vld          (mcif_rx_vld),
        .mcif_rx_dat          (mcif_rx_dat),
        .mcif_rx_rdy          (mcif_rx_rdy),
        .wr_en                (wr_en),
        .wr_row               (wr_row),
        .wr_col_blk           (wr_col_blk),
        .wr_ch_grp            (wr_ch_grp),
        .wr_bank_en           (wr_bank_en),
        .wr_bank_dat          (wr_bank_dat),
        .wr_row_done          (wr_row_done)
    );

endmodule
