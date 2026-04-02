`timescale 1ns / 1ps

module cdma_top #(
    parameter ROW_BLOCKS = 8,
    parameter TK_IN      = 8,
    parameter N          = 8
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       start,

    // 全局配置寄存器 (CSR)
    input  wire [31:0]                cfg_base_addr,
    input  wire [15:0]                cfg_width,     
    input  wire [15:0]                cfg_height,    
    input  wire [15:0]                cfg_ch_groups, 

    // CSC 交互 (用于流控)
    input  wire                       rd_row_free, // CSC 算完释放的脉冲
    input  wire [3:0]                 rd_free_num, // 释放的行数

    // MCIF 接口 (AXI 发包端)
    input  wire                       mcif_req_rdy,
    output wire                       mcif_req_vld,
    output wire [39:0]                mcif_req_pd,

    // MCIF 接口 (AXI 收包端)
    input  wire                       mcif_rx_vld,
    input  wire [2*TK_IN*N-1:0]       mcif_rx_dat,
    output wire                       mcif_rx_rdy,

    // CBUF 写入接口 (下发给 CBUF)
    output wire                       wr_en,
    output wire [15:0]                wr_row,
    output wire [15:0]                wr_col,
    output wire [15:0]                wr_ch_grp,
    output wire [2*TK_IN*N-1:0]       wr_dat,
    output wire                       wr_row_done

    
);

    // ==========================================
    // 例化：发送请求模块
    // ==========================================
    cdma_read_req #(
        .ROW_BLOCKS (ROW_BLOCKS)
    ) u_cdma_read_req (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .cfg_base_addr (cfg_base_addr),
        .cfg_width     (cfg_width),
        .cfg_height    (cfg_height),
        .cfg_ch_groups (cfg_ch_groups),
        .rd_row_free   (rd_row_free),
        .rd_free_num   (rd_free_num),
        .mcif_req_rdy  (mcif_req_rdy),
        .mcif_req_vld  (mcif_req_vld),
        .mcif_req_pd   (mcif_req_pd)
        
    );

    // ==========================================
    // 例化：接收写入模块
    // ==========================================
    cdma_rx_write #(
        .TK_IN (TK_IN),
        .N     (N)
    ) u_cdma_rx_write (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .cfg_width     (cfg_width),
        .cfg_height    (cfg_height),
        .cfg_ch_groups (cfg_ch_groups),
        .mcif_rx_vld   (mcif_rx_vld),
        .mcif_rx_dat   (mcif_rx_dat),
        .mcif_rx_rdy   (mcif_rx_rdy), 
        .wr_en         (wr_en),
        .wr_row        (wr_row),
        .wr_col        (wr_col),
        .wr_ch_grp     (wr_ch_grp),
        .wr_dat        (wr_dat),
        .wr_row_done   (wr_row_done)
        
    );

endmodule