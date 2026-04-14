`timescale 1ns / 1ps

module mem_domain_top #(
    parameter BANK_NUM    = 8,
    parameter TK_IN       = 8,
    parameter N           = 8,
    parameter ADDR_WIDTH  = 10,
    parameter ROW_BLOCKS  = 8,
    parameter BBUF_ADDR_W = 9
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,
    input  wire [ADDR_WIDTH-1:0]              cfg_max_col_blocks,
    input  wire [ADDR_WIDTH-1:0]              cfg_max_ch_groups,
    input  wire [3:0]                         cfg_min_calc_rows,
    input  wire [15:0]                        cfg_height,
    input  wire                               cbuf_wr_en,
    input  wire [15:0]                        cbuf_wr_row,
    input  wire [15:0]                        cbuf_wr_col_blk,
    input  wire [15:0]                        cbuf_wr_ch_grp,
    input  wire [BANK_NUM-1:0]                cbuf_wr_bank_en,
    input  wire [BANK_NUM*TK_IN*N-1:0]        cbuf_wr_bank_dat,
    input  wire                               cbuf_wr_row_done,
    output wire                               cbuf_can_write,
    input  wire [7:0]                         cbuf_rd_en,
    input  wire [15:0]                        cbuf_rd_row,
    input  wire [15:0]                        cbuf_rd_col_align,
    input  wire [15:0]                        cbuf_rd_ch_grp,
    input  wire                               cbuf_rd_row_free,
    input  wire [3:0]                         cbuf_rd_free_num,
    output wire                               cbuf_can_read,
    output wire                               cbuf_rd_dat_vld,
    output wire [BANK_NUM*TK_IN*N-1:0]        cbuf_rd_dat_out,
    output wire [15:0]                        cbuf_status_wr_row_ptr,
    output wire [15:0]                        cbuf_status_rd_row_ptr,
    input  wire [BANK_NUM-1:0]                wbuf_wr_bank_en,
    input  wire [7:0]                         wbuf_wr_offset,
    input  wire [127:0]                       wbuf_wr_dat,
    input  wire                               wbuf_wr_region_done,
    input  wire                               cfg_wt_resident_en,
    input  wire [15:0]                        cfg_wbuf_total_regions,
    output wire                               wbuf_can_write,
    input  wire [BANK_NUM-1:0]                wbuf_csc_rd_en,
    input  wire                               wbuf_csc_step_en,
    input  wire                               wbuf_csc_offset_clr,
    input  wire                               wbuf_csc_region_done,
    input  wire [1:0]                         wbuf_csc_region_idx,
    output wire                               wbuf_can_read,
    output wire                               wbuf_rd_dat_vld,
    output wire [BANK_NUM*128-1:0]            wbuf_rd_dat_out,
    input  wire [BANK_NUM-1:0]                bbuf_wr_en,
    input  wire [BBUF_ADDR_W-1:0]             bbuf_wr_addr,
    input  wire [BANK_NUM*64-1:0]             bbuf_wr_dat,
    input  wire [BANK_NUM-1:0]                bbuf_cacc_rd_en,
    input  wire [BBUF_ADDR_W-1:0]             bbuf_cacc_rd_addr,
    output wire                               bbuf_cacc_rd_vld,
    output wire [BANK_NUM*64-1:0]             bbuf_cacc_rd_dat
);

    cbuf_dat_top #(
        .BANK_NUM   (BANK_NUM),
        .TK_IN      (TK_IN),
        .N          (N),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ROW_BLOCKS (ROW_BLOCKS)
    ) u_cbuf (
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (start),
        .cfg_max_col_blocks (cfg_max_col_blocks),
        .cfg_max_ch_groups  (cfg_max_ch_groups),
        .cfg_min_calc_rows  (cfg_min_calc_rows),
        .cfg_height         (cfg_height),
        .wr_en              (cbuf_wr_en),
        .wr_row             (cbuf_wr_row),
        .wr_col_blk         (cbuf_wr_col_blk),
        .wr_ch_grp          (cbuf_wr_ch_grp),
        .wr_bank_en         (cbuf_wr_bank_en),
        .wr_bank_dat        (cbuf_wr_bank_dat),
        .wr_row_done        (cbuf_wr_row_done),
        .cbuf_can_write     (cbuf_can_write),
        .rd_en              (cbuf_rd_en),
        .rd_row             (cbuf_rd_row),
        .rd_col_align       (cbuf_rd_col_align),
        .rd_ch_grp          (cbuf_rd_ch_grp),
        .rd_row_free        (cbuf_rd_row_free),
        .rd_free_num        (cbuf_rd_free_num),
        .cbuf_can_read      (cbuf_can_read),
        .rd_dat_vld         (cbuf_rd_dat_vld),
        .rd_dat_out         (cbuf_rd_dat_out),
        .status_wr_row_ptr  (cbuf_status_wr_row_ptr),
        .status_rd_row_ptr  (cbuf_status_rd_row_ptr)
    );

    wbuf_dat_top #(
        .BANK_NUM   (BANK_NUM),
        .DATA_WIDTH (128),
        .ADDR_WIDTH (ADDR_WIDTH),
        .REGION_W   (8)
    ) u_wbuf (
        .clk             (clk),
        .rst_n           (rst_n),
        .start           (start),
        .wr_bank_en      (wbuf_wr_bank_en),
        .wr_offset       (wbuf_wr_offset),
        .wr_dat          (wbuf_wr_dat),
        .wr_region_done  (wbuf_wr_region_done),
        .cfg_wt_resident_en (cfg_wt_resident_en),
        .cfg_total_regions  (cfg_wbuf_total_regions),
        .wbuf_can_write  (wbuf_can_write),
        .csc_wt_rd_en    (wbuf_csc_rd_en),
        .csc_step_en     (wbuf_csc_step_en),
        .csc_offset_clr  (wbuf_csc_offset_clr),
        .csc_region_done (wbuf_csc_region_done),
        .csc_region_idx  (wbuf_csc_region_idx),
        .wbuf_can_read   (wbuf_can_read),
        .rd_dat_vld      (wbuf_rd_dat_vld),
        .rd_dat_out      (wbuf_rd_dat_out)
    );

    bbuf_dat_top #(
        .BANK_NUM   (BANK_NUM),
        .DATA_WIDTH (64),
        .ADDR_WIDTH (BBUF_ADDR_W)
    ) u_bbuf (
        .clk            (clk),
        .rst_n          (rst_n),
        .b_cdma_wr_en   (bbuf_wr_en),
        .b_cdma_wr_addr (bbuf_wr_addr),
        .b_cdma_wr_dat  (bbuf_wr_dat),
        .cacc_rd_en     (bbuf_cacc_rd_en),
        .cacc_rd_addr   (bbuf_cacc_rd_addr),
        .cacc_rd_vld    (bbuf_cacc_rd_vld),
        .cacc_rd_dat    (bbuf_cacc_rd_dat)
    );

endmodule
