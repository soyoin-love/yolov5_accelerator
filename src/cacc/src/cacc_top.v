`timescale 1ns / 1ps

module cacc_top #(
    parameter PIXEL_NUM     = 8,
    parameter OUT_CH_NUM    = 16,    // 映射到 requant 的 TOTAL_OUT_CH
    parameter PSUM_W        = 19,
    parameter ACC_W         = 25,    
    parameter BANK_NUM      = 8,     // 用于 BBUF 的 Bank 数量
    parameter OBUF_BANK_NUM = BANK_NUM * 2 // 16，专门用于 OBUF 接口
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,
    input  wire [15:0]                        cfg_b_total_beats,

    // 1. CMAC 阵列输入
    input  wire                               mac_valid,
    input  wire [PIXEL_NUM-1:0]               mac_pixel_mask,   // 屏蔽某列
    input  wire                               mac_is_last_ci,
    input  wire [15:0]                        mac_co_grp,       // 通道轮次
    input  wire [PIXEL_NUM*OUT_CH_NUM*PSUM_W-1:0] psum_in,
    output wire                               cacc_ready,

    // 2. BBUF 读接口 (偏置预取)
    output wire [BANK_NUM-1:0]                bbuf_rd_en,
    output wire [8:0]                         bbuf_rd_addr,
    input  wire [BANK_NUM*64-1:0]             bbuf_rd_dat,      // 8 * 64 = 512 bit
    
    // 3. CSR 配置
    input  wire [15:0]                        cfg_out_ch_groups,// 真实的 8 通道组数量
    input  wire                               cfg_relu_en,

    // 4. OBUF 写接口 (分离并使用 OBUF_BANK_NUM)
    input  wire                               obuf_can_write,
    output wire                               obuf_wr_vld,
    output wire [OBUF_BANK_NUM-1:0]           obuf_wr_mask,     // 16 bit 掩码
    output wire [OBUF_BANK_NUM*64-1:0]        obuf_wr_dat       // 16 * 64 = 1024 bit
);

    // =========================================================================
    // 内部信号声明
    // =========================================================================
    wire quant_vld, requant_ready;
    wire [PIXEL_NUM-1:0] quant_pixel_mask; 
    wire [15:0] quant_co_grp;
    wire [PIXEL_NUM*OUT_CH_NUM*ACC_W-1:0] quant_data;
    wire [1023:0] requant_params_1024b;
    wire accepted_last_ci = mac_valid && cacc_ready && mac_is_last_ci;

    // =========================================================================
    // A. 核心累加器 (cacc_core)
    // =========================================================================
    cacc_core #(
        .PIXEL_NUM(PIXEL_NUM), 
        .OUT_CH_NUM(OUT_CH_NUM), 
        .PSUM_W(PSUM_W), 
        .ACC_W(ACC_W)          
    ) u_core (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start),
        .mac_valid(mac_valid), 
        .mac_pixel_mask(mac_pixel_mask), 
        .mac_is_last_ci(mac_is_last_ci), 
        .mac_co_grp(mac_co_grp),
        .psum_in(psum_in), 
        .requant_ready(requant_ready), 
        .cacc_ready(cacc_ready),
        .quant_vld(quant_vld), 
        .quant_pixel_mask(quant_pixel_mask), 
        .quant_co_grp(quant_co_grp),
        .quant_data_in(quant_data)
    );

    // =========================================================================
    // B. 偏置与量化参数预取器 (bbuf_prefetcher)
    // =========================================================================
    bbuf_prefetcher #(
        .BANK_NUM(BANK_NUM),   // 保持为 8 
        .DATA_WIDTH(64), 
        .ADDR_WIDTH(9)
    ) u_prefetcher (
        .clk(clk), 
        .rst_n(rst_n),
        .cfg_b_total_beats(cfg_b_total_beats),
        .mac_accept_last_ci(accepted_last_ci),
        .mac_accept_co_grp(mac_co_grp),
        .bbuf_rd_en(bbuf_rd_en), 
        .bbuf_rd_addr(bbuf_rd_addr), 
        .bbuf_rd_dat(bbuf_rd_dat),
        .requant_params_1024b(requant_params_1024b)
    );

    // =========================================================================
    // C. 格式化与量化模块 (cacc_requant)
    // =========================================================================
    cacc_requant #(
        .PIXEL_NUM(PIXEL_NUM), 
        .TOTAL_OUT_CH(OUT_CH_NUM), 
        .ACC_W(ACC_W), 
        .BANK_NUM(BANK_NUM),
        .OBUF_BANK_NUM(OBUF_BANK_NUM) // 传递 16
    ) u_requant (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start),

        // CACC Core 交互
        .quant_vld(quant_vld), 
        .quant_pixel_mask(quant_pixel_mask), 
        .quant_data_in(quant_data), 
        .quant_co_grp(quant_co_grp),       
        .requant_ready(requant_ready),

        // CSR 配置接口 
        .cfg_out_ch_groups(cfg_out_ch_groups), 

        // Prefetcher 参数
        .requant_params_1024b(requant_params_1024b), 
        .cfg_relu_en(cfg_relu_en),

        // OBUF 写接口 
        .obuf_can_write(obuf_can_write),
        .obuf_wr_vld(obuf_wr_vld),
        .obuf_wr_mask(obuf_wr_mask),     
        .obuf_wr_dat(obuf_wr_dat)         
    );

endmodule
