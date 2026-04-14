`timescale 1ns / 1ps

module yolo_accel_top #(
    // 全局硬件参数
    parameter BANK_NUM            = 8,
    parameter TK_IN               = 8,
    parameter N                   = 8,
    parameter TK_OUT              = 16,
    parameter OUT_W               = 19,
    parameter ACC_W               = 25,
    parameter PIXEL_NUM           = 8,
    parameter OUT_CH_NUM          = 16,
    
    parameter REGION_W            = 8,   
    parameter AXI_DATA_WIDTH      = 128,
    parameter MAX_BURST_LEN       = 256,
    parameter LOG2_MAX_BURST_LEN  = 8,
    
    parameter ROW_BLOCKS          = 8,
    parameter CBUF_ADDR_W         = 10,
    parameter BBUF_ADDR_W         = 9,
    parameter OBUF_ADDR_W         = 9,
    parameter RBUF_ADDR_W         = 9,
    parameter RBUF_ROW_BLOCKS     = 2,
    
    parameter MAC_LATENCY         = 7,
    parameter TREE_LATENCY        = 3,
    parameter WDMA_MAX_BURST      = 256,
    parameter C_M_AXI_ID_WIDTH    = 2
)(
    input  wire                               clk,
    input  wire                               rst_n,

    // ==========================================
    // 0. 发令枪 (Start Signals)
    // ==========================================
    input  wire                               w_cdma_start,
    input  wire                               f_cdma_start,
    input  wire                               b_cdma_start,
    input  wire                               buf_start,
    input  wire                               csc_start,
    input  wire                               cacc_start,
    input  wire                               pool_start,
    input  wire                               r_cdma_start,
    input  wire                               rbuf_start,
    input  wire                               resadd_start,
    input  wire                               obuf_start,
    input  wire                               wdma_start,

    output wire                               w_cdma_done,
    output wire                               b_cdma_done,
    output wire                               csc_row_done,
    output wire                               wdma_done,
    // ==========================================
    // 1. 软件配置寄存器 (CSR Inputs)
    // ==========================================
    // 权重 CDMA 配置
    input  wire [27:0]                        cfg_wt_total_beats,
    input  wire [31:0]                        cfg_wt_base_addr,
    input  wire [15:0]                        cfg_wt_coords_per_region,
    input  wire [3:0]                         cfg_wt_active_banks,
    input  wire                               cfg_wt_is_odd_oc,
    input  wire [31:0]                        cfg_f_base_addr,
    input  wire [15:0]                        cfg_in_width,
    input  wire [15:0]                        cfg_in_height,
    input  wire [15:0]                        cfg_in_ch_groups,
    input  wire                               cfg_cat_en,
    input  wire                               cfg_cat_src0_upsample,
    input  wire [31:0]                        cfg_cat_src1_base_addr,
    input  wire [15:0]                        cfg_cat_src0_ch_groups,
    input  wire [31:0]                        cfg_cat_src0_line_stride,
    input  wire [31:0]                        cfg_cat_src1_line_stride,
    input  wire [31:0]                        cfg_cat_src0_surface_stride,
    input  wire [31:0]                        cfg_cat_src1_surface_stride,
    input  wire [31:0]                        cfg_b_base_addr,
    input  wire [15:0]                        cfg_out_channels,
    input  wire [15:0]                        cfg_out_width,
    input  wire [15:0]                        cfg_out_height,
    input  wire [31:0]                        cfg_wdma_base_addr,
    input  wire [31:0]                        cfg_res_base_addr,

    // 特征图 CDMA 配置

    // 偏置 CDMA 配置

    // 缓存域维度配置

    // 调度器 CSC 配置
    input  wire [3:0]                         cfg_csc_kx,           
    input  wire [3:0]                         cfg_csc_ky,           
    input  wire [3:0]                         cfg_csc_stride_x,
    input  wire [3:0]                         cfg_csc_stride_y,
    input  wire [3:0]                         cfg_csc_pad_left,
    input  wire [3:0]                         cfg_csc_pad_up,
    input  wire [3:0]                         cfg_csc_active_banks,
    

    // 累加器 CACC 配置
    input  wire [15:0]                        cfg_cacc_b_total_beats,
    input  wire                               cfg_cacc_relu_en,

    // 写回 DMA 配置
    input  wire [1:0]                         cfg_op_mode,
    input  wire                               cfg_pool_pad_zero,
    input  wire                               cfg_resadd_relu_en,
    // input  wire [15:0]                        cfg_wdma_total_cols,
    // input  wire [15:0]                        cfg_wdma_total_rows,

    // ==========================================
    // 2. AXI4 Master 总线接口 (MCIF 外部引脚)
    // ==========================================
    output wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_AWID,
    output wire [31:0]                        M_AXI_AWADDR,
    output wire [7:0]                         M_AXI_AWLEN,
    output wire [2:0]                         M_AXI_AWSIZE,
    output wire [1:0]                         M_AXI_AWBURST,
    output wire                               M_AXI_AWLOCK,
    output wire [3:0]                         M_AXI_AWCACHE,
    output wire [2:0]                         M_AXI_AWPROT,
    output wire [3:0]                         M_AXI_AWQOS,
    output wire                               M_AXI_AWVALID,
    input  wire                               M_AXI_AWREADY,
    
    output wire [AXI_DATA_WIDTH-1:0]          M_AXI_WDATA,
    output wire [AXI_DATA_WIDTH/8-1:0]        M_AXI_WSTRB,
    output wire                               M_AXI_WLAST,
    output wire                               M_AXI_WVALID,
    input  wire                               M_AXI_WREADY,
    
    input  wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_BID,
    input  wire [1:0]                         M_AXI_BRESP,
    input  wire                               M_AXI_BVALID,
    output wire                               M_AXI_BREADY,
    
    output wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_ARID,
    output wire [31:0]                        M_AXI_ARADDR,
    output wire [7:0]                         M_AXI_ARLEN,
    output wire [2:0]                         M_AXI_ARSIZE,
    output wire [1:0]                         M_AXI_ARBURST,
    output wire                               M_AXI_ARLOCK,
    output wire [3:0]                         M_AXI_ARCACHE,
    output wire [2:0]                         M_AXI_ARPROT,
    output wire [3:0]                         M_AXI_ARQOS,
    output wire                               M_AXI_ARVALID,
    input  wire                               M_AXI_ARREADY,
    
    input  wire [C_M_AXI_ID_WIDTH-1:0]        M_AXI_RID,
    input  wire [AXI_DATA_WIDTH-1:0]          M_AXI_RDATA,
    input  wire [1:0]                         M_AXI_RRESP,
    input  wire                               M_AXI_RLAST,
    input  wire                               M_AXI_RVALID,
    output wire                               M_AXI_RREADY
);

    // =========================================================================
    // 内部线网声明 (Internal Wire Declarations)
    // =========================================================================

    // --- MCIF 读通道线网 ---
    localparam OP_CONV   = 2'd0;
    localparam OP_POOL   = 2'd1;
    localparam OP_RESADD = 2'd2;

    // 统一在顶层做像素块数和通道组换算，软件只保留一份输入/输出通道语义。
    // 其中 CSC 使用 16 通道组，OBUF/WDMA/Pool/ResAdd 使用 8 通道组。
    wire [15:0] cfg_f_width          = cfg_in_width;
    // 统一在顶层完成像素块数和通道组数换算，软件侧只保留输入/输出的基础语义量。
    // 其中 CSC 使用 16 通道一组，OBUF/WDMA/Pool/ResAdd/RBUF 使用 8 通道一组。

    wire [15:0] cfg_f_height         = cfg_in_height;
    wire [15:0] cfg_f_ch_groups      = cfg_in_ch_groups;
    wire [15:0] cfg_b_out_channels   = cfg_out_channels;
    wire [15:0] cfg_csc_w_in         = cfg_in_width;
    wire [15:0] cfg_csc_h_in         = cfg_in_height;
    wire [15:0] cfg_csc_w_out        = cfg_out_width;
    wire [15:0] cfg_csc_h_out        = cfg_out_height;
    wire [15:0] cfg_csc_w_out_blocks = (cfg_out_width + 16'd7)  >> 3;
    wire [15:0] cfg_csc_ci_groups    = cfg_in_ch_groups;
    wire [15:0] cfg_csc_co_groups    = (cfg_out_channels + 16'd15) >> 4;
    wire [15:0] cfg_wt_total_co_groups = cfg_csc_co_groups;
    wire [15:0] cfg_out_ch_groups    = (cfg_out_channels + 16'd7)  >> 3;
    wire [CBUF_ADDR_W-1:0] cfg_buf_max_col_blocks = (cfg_in_width  + 16'd7) >> 3;
    wire [CBUF_ADDR_W-1:0] cfg_buf_max_ch_groups  = cfg_in_ch_groups[CBUF_ADDR_W-1:0];
    wire [3:0]             cfg_buf_min_calc_rows  = cfg_csc_ky;
    wire [RBUF_ADDR_W-1:0] cfg_rbuf_max_col_blocks = (cfg_out_width + 16'd7) >> 3;
    wire [RBUF_ADDR_W-1:0] cfg_rbuf_max_ch_groups  = cfg_out_ch_groups[RBUF_ADDR_W-1:0];

    wire                                mcif_rd_req_vld[0:3];
    wire                                mcif_rd_req_rdy[0:3];
    wire [39:0]                         mcif_rd_req_pd [0:3];
    wire                                mcif_rd_resp_vld[0:3];
    wire                                mcif_rd_resp_rdy[0:3];
    wire [AXI_DATA_WIDTH-1:0]           mcif_rd_resp_pd [0:3];

    // --- MCIF 写通道线网 ---
    wire                                mcif_wr_req_vld[0:3];
    wire                                mcif_wr_req_rdy[0:3];
    wire [128:0]                        mcif_wr_req_pd [0:3];
    wire                                mcif_wr_rsp_comp[0:3];
    wire                                mcif_complete = mcif_wr_rsp_comp[0];

    // --- WBUF 交互线网 ---
    wire                                wbuf_can_write;
    wire [BANK_NUM-1:0]                 wbuf_wr_bank_en;
    wire [REGION_W-1:0]                 wbuf_wr_offset;
    wire [AXI_DATA_WIDTH-1:0]           wbuf_wr_dat;
    wire                                wbuf_wr_region_done;
    
    wire                                wbuf_can_read;
    wire [BANK_NUM-1:0]                 wbuf_rd_en;
    wire                                wbuf_step_en;
    wire                                wbuf_offset_clr;
    wire                                wbuf_region_done;
    wire                                wbuf_rd_dat_vld;
    wire [BANK_NUM*AXI_DATA_WIDTH-1:0]  wbuf_rd_dat_out;

    // --- CBUF 交互线网 ---
    wire                                cbuf_can_write;
    wire                                cbuf_wr_en;
    wire [15:0]                         cbuf_wr_row;
    wire [15:0]                         cbuf_wr_col_blk;
    wire [15:0]                         cbuf_wr_ch_grp;
    wire [BANK_NUM-1:0]                 cbuf_wr_bank_en;
    wire [BANK_NUM*TK_IN*N-1:0]         cbuf_wr_bank_dat;
    wire                                cbuf_wr_row_done;

    wire [7:0]                          cbuf_rd_en;
    wire [15:0]                         cbuf_rd_row;
    wire [15:0]                         cbuf_rd_col_align;
    wire [15:0]                         cbuf_rd_ch_grp;
    wire                                cbuf_rd_row_free;
    wire [3:0]                          cbuf_rd_free_num;
    wire                                cbuf_can_read;
    wire                                cbuf_rd_dat_vld;
    wire [BANK_NUM*TK_IN*N-1:0]         cbuf_rd_dat_out;
    wire [15:0]                         cbuf_status_wr_row_ptr;
    wire [15:0]                         cbuf_status_rd_row_ptr;

    wire [7:0]                          csc_cbuf_rd_en;
    wire [15:0]                         csc_cbuf_rd_row;
    wire [15:0]                         csc_cbuf_rd_col_align;
    wire [15:0]                         csc_cbuf_rd_ch_grp;
    wire                                csc_cbuf_rd_row_free;
    wire [3:0]                          csc_cbuf_rd_free_num;

    wire [7:0]                          pool_cbuf_rd_en;
    wire [15:0]                         pool_cbuf_rd_row;
    wire [15:0]                         pool_cbuf_rd_col_align;
    wire [15:0]                         pool_cbuf_rd_ch_grp;
    wire                                pool_cbuf_rd_row_free;
    wire [3:0]                          pool_cbuf_rd_free_num;
    wire                                pool_done;

    wire [7:0]                          resadd_cbuf_rd_en;
    wire [15:0]                         resadd_cbuf_rd_row;
    wire [15:0]                         resadd_cbuf_rd_col_align;
    wire [15:0]                         resadd_cbuf_rd_ch_grp;
    wire                                resadd_cbuf_rd_row_free;
    wire [3:0]                          resadd_cbuf_rd_free_num;

    // RBUF is an independent residual-input line buffer; it is only read by ResAdd.
    wire                                rbuf_wr_en;
    wire [15:0]                         rbuf_wr_row;
    wire [15:0]                         rbuf_wr_col;
    wire [15:0]                         rbuf_wr_ch_grp;
    wire [2*TK_IN*N-1:0]                rbuf_wr_dat;
    wire                                rbuf_wr_pending;
    wire                                rbuf_wr_row_done;
    wire                                rbuf_can_write;
    wire [7:0]                          resadd_rbuf_rd_en;
    wire [15:0]                         resadd_rbuf_rd_row;
    wire [15:0]                         resadd_rbuf_rd_col_align;
    wire [15:0]                         resadd_rbuf_rd_ch_grp;
    wire                                resadd_rbuf_rd_row_free;
    wire [3:0]                          resadd_rbuf_rd_free_num;
    wire                                rbuf_can_read;
    wire                                rbuf_rd_dat_vld;
    wire [BANK_NUM*TK_IN*N-1:0]         rbuf_rd_dat_out;
    wire [15:0]                         rbuf_status_wr_row_ptr;
    wire [15:0]                         rbuf_status_rd_row_ptr;

    // --- BBUF 交互线网 ---
    wire [BANK_NUM-1:0]                 bbuf_wr_en;
    wire [BBUF_ADDR_W-1:0]              bbuf_wr_addr;
    wire [BANK_NUM*64-1:0]              bbuf_wr_dat;

    wire [BANK_NUM-1:0]                 bbuf_rd_en;
    wire [BBUF_ADDR_W-1:0]              bbuf_rd_addr;
    wire                                bbuf_rd_vld;
    wire [BANK_NUM*64-1:0]              bbuf_rd_dat;

    // --- CSC & MAC 阵列交互线网 ---
    wire                                mac_buf_ready;
    wire [BANK_NUM*TK_IN*N-1:0]         mac_features_in;
    wire                                csc_mac_valid;
    wire [7:0]                          csc_mac_pixel_mask;
    wire [15:0]                         csc_mac_co_grp;
    wire                                csc_mac_is_last_ci;

    // --- MAC 阵列 & CACC 交互线网 ---
    wire [BANK_NUM*TK_OUT*OUT_W-1:0]    mac_psum_out;
    wire                                mac_cacc_valid;
    wire [7:0]                          mac_cacc_pixel_mask;
    wire [15:0]                         mac_cacc_co_grp;
    wire                                mac_cacc_is_last_ci;
    wire                                cacc_ready;

    // --- CACC & OBUF 交互线网 (修正位宽) ---
    wire                                obuf_can_write;
    wire                                cacc_obuf_wr_vld;
    wire [2*BANK_NUM-1:0]               cacc_obuf_wr_mask;     // 修正：8bit -> 16bit
    wire [BANK_NUM*128-1:0]              cacc_obuf_wr_dat;      
    wire                                pool_obuf_wr_vld;
    wire [2*BANK_NUM-1:0]               pool_obuf_wr_mask;
    wire [BANK_NUM*128-1:0]             pool_obuf_wr_dat;
    wire                                resadd_obuf_wr_vld;
    wire [2*BANK_NUM-1:0]               resadd_obuf_wr_mask;
    wire [BANK_NUM*128-1:0]             resadd_obuf_wr_dat;
    wire                                resadd_done;
    wire                                obuf_wr_vld_mux;
    wire [2*BANK_NUM-1:0]               obuf_wr_mask_mux;
    wire [BANK_NUM*128-1:0]             obuf_wr_dat_mux;

    // --- OBUF & WDMA 交互线网 (补全声明) ---
    wire [2*BANK_NUM-1:0]               wdma_obuf_rd_en;
    wire                                wdma_rd_next_g0;
    wire                                wdma_rd_next_g1;
    wire                                obuf_wdma_rd_vld;
    wire [127:0]                        obuf_wdma_rd_dat;
    wire [OBUF_ADDR_W:0]                obuf_used_lines_g0;
    wire [OBUF_ADDR_W:0]                obuf_used_lines_g1;
    wire [3:0]                          cbuf_min_calc_rows_mux;

    assign cbuf_rd_en        = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_en        :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_en          : csc_cbuf_rd_en;
    assign cbuf_rd_row       = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_row       :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_row         : csc_cbuf_rd_row;
    assign cbuf_rd_col_align = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_col_align :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_col_align   : csc_cbuf_rd_col_align;
    assign cbuf_rd_ch_grp    = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_ch_grp    :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_ch_grp      : csc_cbuf_rd_ch_grp;
    assign cbuf_rd_row_free  = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_row_free  :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_row_free    : csc_cbuf_rd_row_free;
    assign cbuf_rd_free_num  = (cfg_op_mode == OP_RESADD) ? resadd_cbuf_rd_free_num  :
                               (cfg_op_mode == OP_POOL)   ? pool_cbuf_rd_free_num    : csc_cbuf_rd_free_num;

    assign obuf_wr_vld_mux   = (cfg_op_mode == OP_RESADD) ? resadd_obuf_wr_vld  :
                               (cfg_op_mode == OP_POOL)   ? pool_obuf_wr_vld    : cacc_obuf_wr_vld;
    assign obuf_wr_mask_mux  = (cfg_op_mode == OP_RESADD) ? resadd_obuf_wr_mask :
                               (cfg_op_mode == OP_POOL)   ? pool_obuf_wr_mask   : cacc_obuf_wr_mask;
    assign obuf_wr_dat_mux   = (cfg_op_mode == OP_RESADD) ? resadd_obuf_wr_dat  :
                               (cfg_op_mode == OP_POOL)   ? pool_obuf_wr_dat    : cacc_obuf_wr_dat;
    assign cbuf_min_calc_rows_mux = (cfg_op_mode == OP_POOL)   ? 4'd5 :
                                    (cfg_op_mode == OP_RESADD) ? 4'd1 : cfg_buf_min_calc_rows;

    // =========================================================================
    // A. 互联矩阵层 (MCIF)
    // =========================================================================
    mcif_4r_4w #(
        .C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
        .LOG2_AXI_MAX_BURST_LEN(LOG2_MAX_BURST_LEN),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH)       
    ) u_mcif_4r_4w (
        .clk(clk), .rst_n(rst_n),
        
        // R Channel 0 (Weight)
        .rd_req_vld0(mcif_rd_req_vld[0]), .rd_req_rdy0(mcif_rd_req_rdy[0]), .rd_req_pd0(mcif_rd_req_pd[0]),
        .rd_resp_vld0(mcif_rd_resp_vld[0]), .rd_resp_rdy0(mcif_rd_resp_rdy[0]), .rd_resp_pd0(mcif_rd_resp_pd[0]),
        // R Channel 1 (Feature)
        .rd_req_vld1(mcif_rd_req_vld[1]), .rd_req_rdy1(mcif_rd_req_rdy[1]), .rd_req_pd1(mcif_rd_req_pd[1]),
        .rd_resp_vld1(mcif_rd_resp_vld[1]), .rd_resp_rdy1(mcif_rd_resp_rdy[1]), .rd_resp_pd1(mcif_rd_resp_pd[1]),
        // R Channel 2 (Bias)
        .rd_req_vld2(mcif_rd_req_vld[2]), .rd_req_rdy2(mcif_rd_req_rdy[2]), .rd_req_pd2(mcif_rd_req_pd[2]),
        .rd_resp_vld2(mcif_rd_resp_vld[2]), .rd_resp_rdy2(mcif_rd_resp_rdy[2]), .rd_resp_pd2(mcif_rd_resp_pd[2]),
        // R Channel 3 (Residual feature)
        .rd_req_vld3(mcif_rd_req_vld[3]), .rd_req_rdy3(mcif_rd_req_rdy[3]), .rd_req_pd3(mcif_rd_req_pd[3]),
        .rd_resp_vld3(mcif_rd_resp_vld[3]), .rd_resp_rdy3(mcif_rd_resp_rdy[3]), .rd_resp_pd3(mcif_rd_resp_pd[3]),

        // W Channel 0 (WDMA)
        .wr_req_vld0(mcif_wr_req_vld[0]), .wr_req_rdy0(mcif_wr_req_rdy[0]), .wr_req_pd0(mcif_wr_req_pd[0]), .wr_rsp_complete0(mcif_wr_rsp_comp[0]),
        // W Channel 1~3 (Unused, Tie-off)
        .wr_req_vld1(1'b0), .wr_req_rdy1(mcif_wr_req_rdy[1]), .wr_req_pd1(129'd0), .wr_rsp_complete1(mcif_wr_rsp_comp[1]),
        .wr_req_vld2(1'b0), .wr_req_rdy2(mcif_wr_req_rdy[2]), .wr_req_pd2(129'd0), .wr_rsp_complete2(mcif_wr_rsp_comp[2]),
        .wr_req_vld3(1'b0), .wr_req_rdy3(mcif_wr_req_rdy[3]), .wr_req_pd3(129'd0), .wr_rsp_complete3(mcif_wr_rsp_comp[3]),

        // AXI4 Physical Ports Mapping
        .M_AXI_AWID(M_AXI_AWID), .M_AXI_AWADDR(M_AXI_AWADDR), .M_AXI_AWLEN(M_AXI_AWLEN), .M_AXI_AWSIZE(M_AXI_AWSIZE),
        .M_AXI_AWBURST(M_AXI_AWBURST), .M_AXI_AWLOCK(M_AXI_AWLOCK), .M_AXI_AWCACHE(M_AXI_AWCACHE), .M_AXI_AWPROT(M_AXI_AWPROT),
        .M_AXI_AWQOS(M_AXI_AWQOS), .M_AXI_AWVALID(M_AXI_AWVALID), .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA), .M_AXI_WSTRB(M_AXI_WSTRB), .M_AXI_WLAST(M_AXI_WLAST), .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY), .M_AXI_BID(M_AXI_BID), .M_AXI_BRESP(M_AXI_BRESP), .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY), .M_AXI_ARID(M_AXI_ARID), .M_AXI_ARADDR(M_AXI_ARADDR), .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE), .M_AXI_ARBURST(M_AXI_ARBURST), .M_AXI_ARLOCK(M_AXI_ARLOCK), .M_AXI_ARCACHE(M_AXI_ARCACHE),
        .M_AXI_ARPROT(M_AXI_ARPROT), .M_AXI_ARQOS(M_AXI_ARQOS), .M_AXI_ARVALID(M_AXI_ARVALID), .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RID(M_AXI_RID), .M_AXI_RDATA(M_AXI_RDATA), .M_AXI_RRESP(M_AXI_RRESP), .M_AXI_RLAST(M_AXI_RLAST),
        .M_AXI_RVALID(M_AXI_RVALID), .M_AXI_RREADY(M_AXI_RREADY)
    );

    // =========================================================================
    // B. 直接内存访问层 (CDMA Domain)
    // =========================================================================
    accel_cdma_domain_top_cat #(
        .BANK_NUM           (BANK_NUM),
        .REGION_W           (REGION_W),
        .AXI_DATA_WIDTH     (AXI_DATA_WIDTH),
        .MAX_BURST_LEN      (MAX_BURST_LEN),
        .LOG2_MAX_BURST_LEN (LOG2_MAX_BURST_LEN),
        .ROW_BLOCKS         (ROW_BLOCKS),
        .TK_IN              (TK_IN),
        .N                  (N),
        .BBUF_ADDR_W        (BBUF_ADDR_W)
    ) u_cdma_domain (
        .clk                    (clk),
        .rst_n                  (rst_n),

        // W_CDMA 端口
        .w_start                (w_cdma_start),
        .w_done                 (w_cdma_done),
        .cfg_wt_total_beats     (cfg_wt_total_beats),
        .cfg_wt_base_addr       (cfg_wt_base_addr),
        .cfg_total_co_groups    (cfg_wt_total_co_groups),  //16输出通道组
        .cfg_coords_per_region  (cfg_wt_coords_per_region),
        .cfg_active_banks       (cfg_wt_active_banks),
        .cfg_is_odd_oc          (cfg_wt_is_odd_oc),
        
        .w_rd_req_vld           (mcif_rd_req_vld[0]),
        .w_rd_req_rdy           (mcif_rd_req_rdy[0]),
        .w_rd_req_pd            (mcif_rd_req_pd[0]),
        .w_rd_resp_vld          (mcif_rd_resp_vld[0]),
        .w_rd_resp_rdy          (mcif_rd_resp_rdy[0]),
        .w_rd_resp_pd           (mcif_rd_resp_pd[0]),
        
        .wbuf_can_write         (wbuf_can_write),
        .wbuf_wr_bank_en        (wbuf_wr_bank_en),
        .wbuf_wr_offset         (wbuf_wr_offset),
        .wbuf_wr_dat            (wbuf_wr_dat),
        .wbuf_wr_region_done    (wbuf_wr_region_done),

        // F_CDMA 端口
        .f_start                (f_cdma_start),
        .cfg_f_base_addr        (cfg_f_base_addr),
        .cfg_f_width            (cfg_f_width),
        .cfg_f_height           (cfg_f_height),
        .cfg_f_ch_groups        (cfg_f_ch_groups),
        .cfg_f_cat_en           (cfg_cat_en),
        .cfg_f_cat_src0_upsample(cfg_cat_src0_upsample),
        .cfg_f_cat_src1_base_addr(cfg_cat_src1_base_addr),
        .cfg_f_cat_src0_ch_groups(cfg_cat_src0_ch_groups),
        .cfg_f_cat_src0_line_stride(cfg_cat_src0_line_stride),
        .cfg_f_cat_src1_line_stride(cfg_cat_src1_line_stride),
        .cfg_f_cat_src0_surface_stride(cfg_cat_src0_surface_stride),
        .cfg_f_cat_src1_surface_stride(cfg_cat_src1_surface_stride),
        
        .f_rd_row_free          (cbuf_rd_row_free),
        .f_rd_free_num          (cbuf_rd_free_num),
        
        .f_mcif_req_rdy         (mcif_rd_req_rdy[1]),
        .f_mcif_req_vld         (mcif_rd_req_vld[1]),
        .f_mcif_req_pd          (mcif_rd_req_pd[1]),
        .f_mcif_rx_vld          (mcif_rd_resp_vld[1]),
        .f_mcif_rx_dat          (mcif_rd_resp_pd[1][2*TK_IN*N-1:0]),
        .f_mcif_rx_rdy          (mcif_rd_resp_rdy[1]),
        
        .cbuf_wr_en             (cbuf_wr_en),
        .cbuf_wr_row            (cbuf_wr_row),
        .cbuf_wr_col_blk        (cbuf_wr_col_blk),
        .cbuf_wr_ch_grp         (cbuf_wr_ch_grp),
        .cbuf_wr_bank_en        (cbuf_wr_bank_en),
        .cbuf_wr_bank_dat       (cbuf_wr_bank_dat),
        .cbuf_wr_row_done       (cbuf_wr_row_done),

        // B_CDMA 端口
        .b_start                (b_cdma_start),
        .b_done                 (b_cdma_done),
        .cfg_b_base_addr        (cfg_b_base_addr),
        .cfg_b_out_channels     (cfg_b_out_channels),
        
        .b_rd_req_vld           (mcif_rd_req_vld[2]),
        .b_rd_req_rdy           (mcif_rd_req_rdy[2]),
        .b_rd_req_pd            (mcif_rd_req_pd[2]),
        .b_rd_resp_vld          (mcif_rd_resp_vld[2]),
        .b_rd_resp_rdy          (mcif_rd_resp_rdy[2]),
        .b_rd_resp_pd           (mcif_rd_resp_pd[2]),
        
        .bbuf_wr_en             (bbuf_wr_en),
        .bbuf_wr_addr           (bbuf_wr_addr),
        .bbuf_wr_dat            (bbuf_wr_dat)
    );

    // Residual feature DMA reuses the feature CDMA data layout:
    // DDR beat = 2 pixels * 8 INT8 channels, written into the independent RBUF.
    r_cdma_top #(
        .ROW_BLOCKS (RBUF_ROW_BLOCKS),
        .TK_IN      (TK_IN),
        .N          (N)
    ) u_r_cdma (
        .clk              (clk),
        .rst_n            (rst_n),
        .start            (r_cdma_start),
        .cfg_base_addr    (cfg_res_base_addr),
        .cfg_width        (cfg_csc_w_out),
        .cfg_height       (cfg_csc_h_out),
        .cfg_ch_groups    (cfg_out_ch_groups),
        .rd_row_free      (resadd_rbuf_rd_row_free),
        .rd_free_num      (resadd_rbuf_rd_free_num),
        .rbuf_can_write   (rbuf_can_write),
        .mcif_req_rdy     (mcif_rd_req_rdy[3]),
        .mcif_req_vld     (mcif_rd_req_vld[3]),
        .mcif_req_pd      (mcif_rd_req_pd[3]),
        .mcif_rx_vld      (mcif_rd_resp_vld[3]),
        .mcif_rx_dat      (mcif_rd_resp_pd[3][2*TK_IN*N-1:0]),
        .mcif_rx_rdy      (mcif_rd_resp_rdy[3]),
        .wr_en            (rbuf_wr_en),
        .wr_row           (rbuf_wr_row),
        .wr_col           (rbuf_wr_col),
        .wr_ch_grp        (rbuf_wr_ch_grp),
        .wr_dat           (rbuf_wr_dat),
        .wr_pending       (rbuf_wr_pending),
        .wr_row_done      (rbuf_wr_row_done)
    );

    // =========================================================================
    // C. 片上缓存池层 (Memory Domain)
    // =========================================================================
    mem_domain_top #(
        .BANK_NUM           (BANK_NUM),
        .TK_IN              (TK_IN),
        .N                  (N),
        .ADDR_WIDTH         (CBUF_ADDR_W),
        .ROW_BLOCKS         (ROW_BLOCKS),
        .BBUF_ADDR_W        (BBUF_ADDR_W)
    ) u_mem_domain (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .start                  (buf_start),
        
        // 全局特征配置
        .cfg_max_col_blocks     (cfg_buf_max_col_blocks),
        .cfg_max_ch_groups      (cfg_buf_max_ch_groups),
        .cfg_min_calc_rows      (cbuf_min_calc_rows_mux),
        .cfg_height             (cfg_f_height),

        // CBUF 端口
        .cbuf_wr_en             (cbuf_wr_en),
        .cbuf_wr_row            (cbuf_wr_row),
        .cbuf_wr_col_blk        (cbuf_wr_col_blk),
        .cbuf_wr_ch_grp         (cbuf_wr_ch_grp),
        .cbuf_wr_bank_en        (cbuf_wr_bank_en),
        .cbuf_wr_bank_dat       (cbuf_wr_bank_dat),
        .cbuf_wr_row_done       (cbuf_wr_row_done),
        .cbuf_can_write         (cbuf_can_write),
        
        .cbuf_rd_en             (cbuf_rd_en),
        .cbuf_rd_row            (cbuf_rd_row),
        .cbuf_rd_col_align      (cbuf_rd_col_align),
        .cbuf_rd_ch_grp         (cbuf_rd_ch_grp),
        .cbuf_rd_row_free       (cbuf_rd_row_free),
        .cbuf_rd_free_num       (cbuf_rd_free_num),
        .cbuf_can_read          (cbuf_can_read),
        .cbuf_rd_dat_vld        (cbuf_rd_dat_vld),
        .cbuf_rd_dat_out        (cbuf_rd_dat_out),
        .cbuf_status_wr_row_ptr (cbuf_status_wr_row_ptr),
        .cbuf_status_rd_row_ptr (cbuf_status_rd_row_ptr),

        // WBUF 端口
        .wbuf_wr_bank_en        (wbuf_wr_bank_en),
        .wbuf_wr_offset         (wbuf_wr_offset),
        .wbuf_wr_dat            (wbuf_wr_dat),
        .wbuf_wr_region_done    (wbuf_wr_region_done),
        .wbuf_can_write         (wbuf_can_write),
        .wbuf_csc_offset_clr    (wbuf_offset_clr),
        .wbuf_csc_region_done   (wbuf_region_done),
        .wbuf_csc_rd_en         (wbuf_rd_en),
        .wbuf_csc_step_en       (wbuf_step_en),
        
        .wbuf_can_read          (wbuf_can_read),
        .wbuf_rd_dat_vld        (wbuf_rd_dat_vld),
        .wbuf_rd_dat_out        (wbuf_rd_dat_out),

        // BBUF 端口
        .bbuf_wr_en             (bbuf_wr_en),
        .bbuf_wr_addr           (bbuf_wr_addr),
        .bbuf_wr_dat            (bbuf_wr_dat),
        
        .bbuf_cacc_rd_en        (bbuf_rd_en),
        .bbuf_cacc_rd_addr      (bbuf_rd_addr),
        .bbuf_cacc_rd_vld       (bbuf_rd_vld),
        .bbuf_cacc_rd_dat       (bbuf_rd_dat)
    );

    rbuf_dat_top #(
        .BANK_NUM   (BANK_NUM),
        .TK_IN      (TK_IN),
        .N          (N),
        .ADDR_WIDTH (RBUF_ADDR_W),
        .ROW_BLOCKS (RBUF_ROW_BLOCKS)
    ) u_rbuf (
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (rbuf_start),
        // RBUF 的地址空间应跟随输出块数/输出 8 通道组，而不是复用 CBUF 的输入配置。
        .cfg_max_col_blocks (cfg_rbuf_max_col_blocks),
        .cfg_max_ch_groups  (cfg_rbuf_max_ch_groups),
        .cfg_min_calc_rows  (4'd1),
        .cfg_height         (cfg_csc_h_out),
        .wr_en              (rbuf_wr_en),
        .wr_row             (rbuf_wr_row),
        .wr_col             (rbuf_wr_col),
        .wr_ch_grp          (rbuf_wr_ch_grp),
        .wr_dat             (rbuf_wr_dat),
        .wr_pending         (rbuf_wr_pending),
        .wr_row_done        (rbuf_wr_row_done),
        .rbuf_can_write     (rbuf_can_write),
        .rd_en              (resadd_rbuf_rd_en),
        .rd_row             (resadd_rbuf_rd_row),
        .rd_col_align       (resadd_rbuf_rd_col_align),
        .rd_ch_grp          (resadd_rbuf_rd_ch_grp),
        .rd_row_free        (resadd_rbuf_rd_row_free),
        .rd_free_num        (resadd_rbuf_rd_free_num),
        .rbuf_can_read      (rbuf_can_read),
        .rd_dat_vld         (rbuf_rd_dat_vld),
        .rd_dat_out         (rbuf_rd_dat_out),
        .status_wr_row_ptr  (rbuf_status_wr_row_ptr),
        .status_rd_row_ptr  (rbuf_status_rd_row_ptr)
    );

    // =========================================================================
    // D. 调度器与计算引擎层 (CSC & MAC)
    // =========================================================================
    csc_dat #(
        .BANK_NUM(BANK_NUM), .TK_IN(TK_IN), .N(N)
    ) u_csc (
        .clk(clk), .rst_n(rst_n), .start(csc_start),
        .cfg_w_out(cfg_csc_w_out), .cfg_w_out_blocks(cfg_csc_w_out_blocks), .cfg_h_out(cfg_csc_h_out),        
        .cfg_w_in(cfg_csc_w_in), .cfg_h_in(cfg_csc_h_in), .cfg_co_groups(cfg_csc_co_groups),    
        .cfg_ci_groups(cfg_csc_ci_groups), .cfg_kx(cfg_csc_kx), .cfg_ky(cfg_csc_ky),           
        .cfg_stride_x(cfg_csc_stride_x), .cfg_stride_y(cfg_csc_stride_y), .cfg_pad_left(cfg_csc_pad_left),     
        .cfg_pad_up(cfg_csc_pad_up), .cfg_active_banks(cfg_csc_active_banks), .csc_row_done(csc_row_done),
        
        .cbuf_can_read(cbuf_can_read), .cbuf_rd_en(csc_cbuf_rd_en), .cbuf_rd_row(csc_cbuf_rd_row),
        .cbuf_rd_col_align(csc_cbuf_rd_col_align), .cbuf_rd_ch_grp(csc_cbuf_rd_ch_grp),
        .cbuf_rd_row_free(csc_cbuf_rd_row_free), .cbuf_rd_free_num(csc_cbuf_rd_free_num), .cbuf_rd_dat(cbuf_rd_dat_out),
        
        .wbuf_can_read(wbuf_can_read), .wbuf_rd_en(wbuf_rd_en),
        .wbuf_step_en(wbuf_step_en), .wbuf_offset_clr(wbuf_offset_clr), .wbuf_region_done(wbuf_region_done),

        .mac_buf_ready(mac_buf_ready), .mac_dat(mac_features_in), 
        .mac_valid(csc_mac_valid), .mac_pixel_mask(csc_mac_pixel_mask),
        .mac_co_grp(csc_mac_co_grp), .mac_is_last_ci(csc_mac_is_last_ci) 
    );

    cmac_array #(
        .ROW_NUM(BANK_NUM), .COL_NUM(BANK_NUM), .N(N),
        .TK_IN(TK_IN), .TK_OUT(TK_OUT), .OUT_W(OUT_W),
        .MAC_LATENCY(MAC_LATENCY), .TREE_LATENCY(TREE_LATENCY)
    ) u_mac_array (
        .clk(clk), .rst_n(rst_n),
        .features_in(mac_features_in), .weights_in(wbuf_rd_dat_out),
        .mac_valid_in(csc_mac_valid), .mac_pixel_mask_in(csc_mac_pixel_mask),
        .mac_co_grp_in(csc_mac_co_grp), .mac_is_last_ci_in(csc_mac_is_last_ci),
        
        .psum_out(mac_psum_out),
        .mac_valid_out(mac_cacc_valid), .mac_pixel_mask_out(mac_cacc_pixel_mask),
        .mac_co_grp_out(mac_cacc_co_grp), .mac_is_last_ci_out(mac_cacc_is_last_ci),
        
        .cacc_ready(cacc_ready), .mac_buf_ready(mac_buf_ready) 
    );

    // =========================================================================
    // E. 累加与量化 (CACC) - 修正例化
    // =========================================================================
    cacc_top #(
        .PIXEL_NUM(PIXEL_NUM), 
        .OUT_CH_NUM(OUT_CH_NUM),
        .PSUM_W(OUT_W), 
        .ACC_W(ACC_W), 
        .BANK_NUM(BANK_NUM)            // 移除了多余的 OBUF_BANK_NUM 参数
    ) u_cacc (
        .clk(clk), .rst_n(rst_n), .start(cacc_start),
        .cfg_b_total_beats(cfg_cacc_b_total_beats),
        
        .mac_valid(mac_cacc_valid), 
        .mac_pixel_mask(mac_cacc_pixel_mask),
        .mac_is_last_ci(mac_cacc_is_last_ci), 
        .mac_co_grp(mac_cacc_co_grp),
        .psum_in(mac_psum_out), 
        .cacc_ready(cacc_ready),
        
        .bbuf_rd_en(bbuf_rd_en), 
        .bbuf_rd_addr(bbuf_rd_addr), 
        .bbuf_rd_dat(bbuf_rd_dat),
        
        // 新增的 CSR 接口
        .cfg_out_ch_groups(cfg_out_ch_groups), // 连接真实的8通道组数
        .cfg_relu_en(cfg_cacc_relu_en),
        
        // OBUF 交互 (位宽已对齐)
        .obuf_can_write(obuf_can_write), 
        .obuf_wr_vld(cacc_obuf_wr_vld),
        .obuf_wr_mask(cacc_obuf_wr_mask), 
        .obuf_wr_dat(cacc_obuf_wr_dat)
    );

    pool_top #(
        .BANK_NUM(BANK_NUM),
        .TK_IN(TK_IN),
        .N(N)
    ) u_pool (
        .clk(clk),
        .rst_n(rst_n),
        .start(pool_start),
        .cfg_w_in(cfg_csc_w_in),
        .cfg_h_in(cfg_csc_h_in),
        .cfg_w_out(cfg_csc_w_out),
        .cfg_h_out(cfg_csc_h_out),
        .cfg_ch_groups(cfg_out_ch_groups),
        .cfg_pad_zero(cfg_pool_pad_zero),
        .cbuf_can_read(cbuf_can_read),
        .cbuf_rd_en(pool_cbuf_rd_en),
        .cbuf_rd_row(pool_cbuf_rd_row),
        .cbuf_rd_col_align(pool_cbuf_rd_col_align),
        .cbuf_rd_ch_grp(pool_cbuf_rd_ch_grp),
        .cbuf_rd_row_free(pool_cbuf_rd_row_free),
        .cbuf_rd_free_num(pool_cbuf_rd_free_num),
        .cbuf_rd_dat_vld(cbuf_rd_dat_vld),
        .cbuf_rd_dat(cbuf_rd_dat_out),
        .obuf_can_write(obuf_can_write),
        .obuf_wr_vld(pool_obuf_wr_vld),
        .obuf_wr_mask(pool_obuf_wr_mask),
        .obuf_wr_dat(pool_obuf_wr_dat),
        .pool_done(pool_done)
    );

    resadd_top #(
        .BANK_NUM(BANK_NUM),
        .TK_IN(TK_IN),
        .N(N)
    ) u_resadd (
        .clk(clk),
        .rst_n(rst_n),
        .start(resadd_start),
        .cfg_w_out(cfg_csc_w_out),
        .cfg_h_out(cfg_csc_h_out),
        .cfg_ch_groups(cfg_out_ch_groups),
        .cfg_relu_en(cfg_resadd_relu_en),
        .cbuf_can_read(cbuf_can_read),
        .cbuf_status_wr_row_ptr(cbuf_status_wr_row_ptr),
        .cbuf_status_rd_row_ptr(cbuf_status_rd_row_ptr),
        .cbuf_rd_en(resadd_cbuf_rd_en),
        .cbuf_rd_row(resadd_cbuf_rd_row),
        .cbuf_rd_col_align(resadd_cbuf_rd_col_align),
        .cbuf_rd_ch_grp(resadd_cbuf_rd_ch_grp),
        .cbuf_rd_row_free(resadd_cbuf_rd_row_free),
        .cbuf_rd_free_num(resadd_cbuf_rd_free_num),
        .cbuf_rd_dat_vld(cbuf_rd_dat_vld),
        .cbuf_rd_dat(cbuf_rd_dat_out),
        .rbuf_can_read(rbuf_can_read),
        .rbuf_status_wr_row_ptr(rbuf_status_wr_row_ptr),
        .rbuf_status_rd_row_ptr(rbuf_status_rd_row_ptr),
        .rbuf_rd_en(resadd_rbuf_rd_en),
        .rbuf_rd_row(resadd_rbuf_rd_row),
        .rbuf_rd_col_align(resadd_rbuf_rd_col_align),
        .rbuf_rd_ch_grp(resadd_rbuf_rd_ch_grp),
        .rbuf_rd_row_free(resadd_rbuf_rd_row_free),
        .rbuf_rd_free_num(resadd_rbuf_rd_free_num),
        .rbuf_rd_dat_vld(rbuf_rd_dat_vld),
        .rbuf_rd_dat(rbuf_rd_dat_out),
        .obuf_can_write(obuf_can_write),
        .obuf_wr_vld(resadd_obuf_wr_vld),
        .obuf_wr_mask(resadd_obuf_wr_mask),
        .obuf_wr_dat(resadd_obuf_wr_dat),
        .resadd_done(resadd_done)
    );

    // =========================================================================
    // F. 写回与隔离层 (OBUF + WDMA)
    // =========================================================================
    obuf_dat_top #(
        .BANK_NUM(BANK_NUM * 2),       // 16 Bank
        .DATA_WIDTH(64), 
        .ADDR_WIDTH(OBUF_ADDR_W)
    ) u_obuf (
        .clk(clk), .rst_n(rst_n), .start(obuf_start),
        
        // CACC 写入端
        .cacc_wr_vld(obuf_wr_vld_mux),
        .cacc_wr_bank_en(obuf_wr_mask_mux), // 16bit 掩码直连
        .cacc_wr_dat(obuf_wr_dat_mux),
        .obuf_can_write(obuf_can_write),
        
        // WDMA 读取端
        .wdma_rd_en(wdma_obuf_rd_en), 
        .wdma_rd_next_g0(wdma_rd_next_g0), 
        .wdma_rd_next_g1(wdma_rd_next_g1),
        .obuf_rd_vld(obuf_wdma_rd_vld), 
        .obuf_rd_dat(obuf_wdma_rd_dat),
        
        // 双 FIFO 水位输出
        .obuf_used_lines_g0(obuf_used_lines_g0),
        .obuf_used_lines_g1(obuf_used_lines_g1)
    );

    wdma_core #(
        .MAX_BURST(WDMA_MAX_BURST), 
        .BANK_NUM(16), 
        .ADDR_WIDTH(OBUF_ADDR_W)
    ) u_wdma (
        .clk(clk), .rst_n(rst_n),
        
        // CSR 配置
        .cfg_start(wdma_start), 
        .cfg_base_addr(cfg_wdma_base_addr),   
        .cfg_w_out(cfg_csc_w_out),           
        .cfg_h_out(cfg_csc_h_out),           
        .cfg_co_groups(cfg_out_ch_groups),    

        // OBUF 数据交互
        .obuf_used_lines_g0(obuf_used_lines_g0), 
        .obuf_used_lines_g1(obuf_used_lines_g1),
        .wdma_rd_en(wdma_obuf_rd_en), 
        .wdma_rd_next_g0(wdma_rd_next_g0), 
        .wdma_rd_next_g1(wdma_rd_next_g1),
        .obuf_rd_vld(obuf_wdma_rd_vld), 
        .obuf_rd_dat(obuf_wdma_rd_dat),
        
        // MCIF 写接口
        .mcif_ready(mcif_wr_req_rdy[0]),     
        .mcif_valid(mcif_wr_req_vld[0]), 
        .mcif_data(mcif_wr_req_pd[0]),
        
        .mcif_complete(mcif_complete),    
        .wdma_done(wdma_done)
    );

endmodule
