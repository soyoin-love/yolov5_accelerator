`timescale 1ns / 1ps

module mem_domain_top #(
    parameter BANK_NUM   = 8,
    parameter TK_IN      = 8,
    parameter N          = 8,
    parameter ADDR_WIDTH = 10,
    parameter ROW_BLOCKS = 8,
    parameter BBUF_ADDR_W= 9
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,

    // [全局 CSR]
    input  wire [ADDR_WIDTH-1:0]              cfg_max_col_blocks, 
    input  wire [ADDR_WIDTH-1:0]              cfg_max_ch_groups,  
    input  wire [3:0]                         cfg_min_calc_rows,
    input  wire [15:0]                        cfg_height,

    // ==========================================
    // 1. 特征图 CBUF 接口
    // ==========================================
    // 写接口 (来自 F_CDMA)
    input  wire                               cbuf_wr_en,
    input  wire [15:0]                        cbuf_wr_row,      
    input  wire [15:0]                        cbuf_wr_col,      
    input  wire [15:0]                        cbuf_wr_ch_grp,   
    input  wire [2*TK_IN*N-1:0]               cbuf_wr_dat,      
    input  wire                               cbuf_wr_row_done, 
    output wire                               cbuf_can_write, 

    // 读接口 (去往 CSC 调度)
    input  wire [7:0]                         cbuf_rd_en,
    input  wire [15:0]                        cbuf_rd_row,      
    input  wire [15:0]                        cbuf_rd_col_align, // 现在接收非对齐原始坐标
    input  wire [15:0]                        cbuf_rd_ch_grp,   
    input  wire                               cbuf_rd_row_free, 
    input  wire [3:0]                         cbuf_rd_free_num, 
    output wire                               cbuf_can_read,  

    output wire                               cbuf_rd_dat_vld,
    output wire [BANK_NUM*TK_IN*N-1:0]        cbuf_rd_dat_out, // 延迟 4 拍输出

    // ==========================================
    // 2. 权重 WBUF 接口
    // ==========================================
    // 写接口 (来自 W_CDMA)
    input  wire [BANK_NUM-1:0]                wbuf_wr_bank_en,
    input  wire [7:0]                         wbuf_wr_offset,
    input  wire [127:0]                       wbuf_wr_dat,
    input  wire                               wbuf_wr_region_done,
    output wire                               wbuf_can_write,

    // 读接口 (去往 CSC 调度 - 接口已重构)
    input  wire [BANK_NUM-1:0]                wbuf_csc_rd_en,
    input  wire                               wbuf_csc_step_en,
    input  wire                               wbuf_csc_offset_clr,  // 新增：单个窗口算完指针复位
    input  wire                               wbuf_csc_region_done, // 新增：整行权重用完区域释放
    output wire                               wbuf_can_read,

    output wire                               wbuf_rd_dat_vld,
    output wire [BANK_NUM*128-1:0]            wbuf_rd_dat_out, // 与 CBUF 同步延迟输出

    // ==========================================
    // 3. 偏置 BBUF 接口
    // ==========================================
    // 写接口 (来自 B_CDMA)
    input  wire [BANK_NUM-1:0]                bbuf_wr_en,
    input  wire [BBUF_ADDR_W-1:0]             bbuf_wr_addr,
    input  wire [BANK_NUM*64-1:0]             bbuf_wr_dat,

    // 读接口 (去往 CACC 累加器预取)
    input  wire [BANK_NUM-1:0]                bbuf_cacc_rd_en,
    input  wire [BBUF_ADDR_W-1:0]             bbuf_cacc_rd_addr,
    output wire                               bbuf_cacc_rd_vld,
    output wire [BANK_NUM*64-1:0]             bbuf_cacc_rd_dat
);

    // ==========================================================
    // A. 特征图缓存例化 (4 拍流水线架构)
    // ==========================================================
    cbuf_dat_top #(
        .BANK_NUM(BANK_NUM), 
        .TK_IN(TK_IN), 
        .N(N),
        .ADDR_WIDTH(ADDR_WIDTH), 
        .ROW_BLOCKS(ROW_BLOCKS)
    ) u_cbuf (
        .clk                (clk), 
        .rst_n              (rst_n), 
        .start              (start),
        
        .cfg_max_col_blocks (cfg_max_col_blocks), 
        .cfg_max_ch_groups  (cfg_max_ch_groups),
        .cfg_min_calc_rows  (cfg_min_calc_rows), 
        .cfg_height         (cfg_height),
        
        // 写端口
        .wr_en              (cbuf_wr_en), 
        .wr_row             (cbuf_wr_row), 
        .wr_col             (cbuf_wr_col),
        .wr_ch_grp          (cbuf_wr_ch_grp), 
        .wr_dat             (cbuf_wr_dat), 
        .wr_row_done        (cbuf_wr_row_done),
        .cbuf_can_write     (cbuf_can_write),
        
        // 读端口
        .rd_en              (cbuf_rd_en), 
        .rd_row             (cbuf_rd_row), 
        .rd_col_align       (cbuf_rd_col_align),
        .rd_ch_grp          (cbuf_rd_ch_grp), 
        .rd_row_free        (cbuf_rd_row_free), 
        .rd_free_num        (cbuf_rd_free_num),
        .cbuf_can_read      (cbuf_can_read),
        
        // 数据输出 (4-cycle latency)
        .rd_dat_vld         (cbuf_rd_dat_vld), 
        .rd_dat_out         (cbuf_rd_dat_out)
    );

    // ==========================================================
    // B. 权重缓存例化 (T5 延迟对齐架构)
    // ==========================================================
    wbuf_dat_top #(
        .BANK_NUM   (BANK_NUM), 
        .DATA_WIDTH (128), 
        .ADDR_WIDTH (ADDR_WIDTH), 
        .REGION_W   (8)
    ) u_wbuf (
        .clk                (clk), 
        .rst_n              (rst_n), 
        .start              (start),
        
        // 写端口
        .wr_bank_en         (wbuf_wr_bank_en), 
        .wr_offset          (wbuf_wr_offset),
        .wr_dat             (wbuf_wr_dat), 
        .wr_region_done     (wbuf_wr_region_done),
        .wbuf_can_write     (wbuf_can_write),
        
        // 读端口 (接口已重构)
        .csc_wt_rd_en       (wbuf_csc_rd_en), 
        .csc_step_en        (wbuf_csc_step_en),
        .csc_offset_clr     (wbuf_csc_offset_clr),  // 映射新信号
        .csc_region_done    (wbuf_csc_region_done), // 映射新信号
        .wbuf_can_read      (wbuf_can_read),
        
        // 数据输出 (T5 自动对齐 CBUF)
        .rd_dat_vld         (wbuf_rd_dat_vld), 
        .rd_dat_out         (wbuf_rd_dat_out)
    );

    // ==========================================================
    // C. 偏置缓存例化 (保持 1 拍 BRAM 延迟)
    // ==========================================================
    bbuf_dat_top #(
        .BANK_NUM   (BANK_NUM), 
        .DATA_WIDTH (64), 
        .ADDR_WIDTH (BBUF_ADDR_W)
    ) u_bbuf (
        .clk                (clk), 
        .rst_n              (rst_n),
        
        // 写端口
        .b_cdma_wr_en       (bbuf_wr_en), 
        .b_cdma_wr_addr     (bbuf_wr_addr), 
        .b_cdma_wr_dat      (bbuf_wr_dat),
        
        // 读端口
        .cacc_rd_en         (bbuf_cacc_rd_en), 
        .cacc_rd_addr  (bbuf_cacc_rd_addr),
        .cacc_rd_vld        (bbuf_cacc_rd_vld), 
        .cacc_rd_dat   (bbuf_cacc_rd_dat)
    );

endmodule