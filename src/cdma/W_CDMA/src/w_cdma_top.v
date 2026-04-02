`timescale 1ns / 1ps

module w_cdma_top #(
    parameter BANK_NUM            = 8,
    parameter REGION_W            = 8,   // 区域深度 2^8 = 256
    parameter AXI_DATA_WIDTH      = 128,
    parameter MAX_BURST_LEN       = 256,
    parameter LOG2_MAX_BURST_LEN  = $clog2(MAX_BURST_LEN)
)(
    input  wire                               clk,
    input  wire                               rst_n,

    // ==========================================
    // 1. CSR 控制与配置接口
    // ==========================================
    input  wire                               start,               // 启动脉冲 [cite: 69]
    output wire                               done,                // 全局搬运完成 [cite: 69]
    
    // 命令发送配置
    input  wire [27:0]                        cfg_wt_total_beats,  // 总共需搬运的 128-bit 数量 [cite: 70]
    input  wire [31:0]                        cfg_wt_base_addr,    // 权重 DDR 起始物理地址 [cite: 70]
    
    // 数据分发配置 (三维计数器)
    input  wire [15:0]                        cfg_total_co_groups, // 总 co_grp 数量 [cite: 71]
    input  wire [15:0]                        cfg_coords_per_region,// 每个区域的坐标点总数 [cite: 71]
    input  wire [3:0]                         cfg_active_banks,    // 最后一组使用的有效 Bank 数量 [cite: 71]
    input  wire                               cfg_is_odd_oc,       // 最后一组是否为奇数输出通道 [cite: 72]

    // ==========================================
    // 2. MCIF (AXI) 读请求接口 (AR Channel)
    // ==========================================
    output wire                               rd_req_vld,
    input  wire                               rd_req_rdy,
    output wire [31 + LOG2_MAX_BURST_LEN:0]   rd_req_pd,           // {len, addr} [cite: 73]

    // ==========================================
    // 3. MCIF (AXI) 读响应接口 (R Channel)
    // ==========================================
    input  wire                               rd_resp_vld,
    output wire                               rd_resp_rdy,
    input  wire [AXI_DATA_WIDTH-1:0]          rd_resp_pd,          // [cite: 74]

    // ==========================================
    // 4. WBUF 写接口
    // ==========================================
    input  wire                               wbuf_can_write,      // 来自 WBUF 的反压信号 [cite: 75]
    output wire [BANK_NUM-1:0]                wbuf_wr_bank_en,     // Bank 写掩码 [cite: 75]
    output wire [REGION_W-1:0]                wbuf_wr_offset,      // 区域内线性偏移地址 [cite: 75]
    output wire [AXI_DATA_WIDTH-1:0]          wbuf_wr_dat,         // 128-bit 权重数据 [cite: 75]
    output wire                               wbuf_wr_region_done  // 写完一个区域的脉冲信号 [cite: 76]
);

    // ==========================================
    // A. 读命令发送子模块 [cite: 77]
    // ==========================================
    w_cdma_send_cmd #(
        .MAX_BURST_LEN(MAX_BURST_LEN),
        .LOG2_MAX_BURST_LEN(LOG2_MAX_BURST_LEN)
    ) u_send_cmd (
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (start),
        .cfg_wt_total_beats (cfg_wt_total_beats),
        .cfg_wt_base_addr   (cfg_wt_base_addr),
        .wbuf_can_write     (wbuf_can_write),
        .rd_req_vld         (rd_req_vld),
        .rd_req_rdy         (rd_req_rdy),
        .rd_req_pd          (rd_req_pd)
    );

    // ==========================================
    // B. 数据接收与写 WBUF 子模块 [cite: 79]
    // ==========================================
    w_cdma_recv_data #(
        .BANK_NUM(BANK_NUM), 
        .REGION_W(REGION_W),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    ) u_recv_data (
        .clk                  (clk),
        .rst_n                (rst_n),
        .start                (start),
        // 移除了已废弃的 cfg_wt_size_bytes 和 cfg_wt_total_beats 端口
        .cfg_total_co_groups  (cfg_total_co_groups),
        .cfg_coords_per_region(cfg_coords_per_region),
        .cfg_active_banks     (cfg_active_banks),
        .cfg_is_odd_oc        (cfg_is_odd_oc),
        .done                 (done),
        .rd_resp_vld          (rd_resp_vld),
        .rd_resp_rdy          (rd_resp_rdy),
        .rd_resp_pd           (rd_resp_pd),
        .wbuf_can_write       (wbuf_can_write),
        .wbuf_wr_bank_en      (wbuf_wr_bank_en),
        .wbuf_wr_offset       (wbuf_wr_offset),
        .wbuf_wr_dat          (wbuf_wr_dat),
        .wbuf_wr_region_done  (wbuf_wr_region_done)
    );

endmodule