`timescale 1ns / 1ps

module b_cdma_top #(
    parameter BANK_NUM            = 8,
    parameter AXI_DATA_WIDTH      = 128,
    parameter MAX_BURST_LEN       = 256,
    parameter LOG2_MAX_BURST_LEN  = $clog2(MAX_BURST_LEN),
    parameter BBUF_ADDR_W         = 9
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,
    output wire                               done,

    // CSR
    input  wire [31:0]                        cfg_b_base_addr,
    input  wire [15:0]                        cfg_out_channels,

    // MCIF 接口
    output wire                               rd_req_vld,
    input  wire                               rd_req_rdy,
    output wire [31 + LOG2_MAX_BURST_LEN:0]   rd_req_pd,
    input  wire                               rd_resp_vld,
    output wire                               rd_resp_rdy,
    input  wire [AXI_DATA_WIDTH-1:0]          rd_resp_pd,

    // BBUF 接口
    output wire [BANK_NUM-1:0]                bbuf_wr_en,
    output wire [BBUF_ADDR_W-1:0]             bbuf_wr_addr,
    output wire [BANK_NUM*64-1:0]             bbuf_wr_dat
);
    // 1 beat 携带 2 个通道的参数 (2 * 64-bit = 128-bit) [cite: 590]
    wire [15:0] total_beats = (cfg_out_channels + 1) >> 1;

    b_cdma_send_cmd #(
        .MAX_BURST_LEN(MAX_BURST_LEN),
        .LOG2_MAX_BURST_LEN(LOG2_MAX_BURST_LEN)
    ) u_send (
        .clk(clk), .rst_n(rst_n), .start(start),
        .cfg_b_total_beats(total_beats),
        .cfg_b_base_addr(cfg_b_base_addr),
        .rd_req_vld(rd_req_vld), .rd_req_rdy(rd_req_rdy), .rd_req_pd(rd_req_pd)
    );

    b_cdma_recv_data #(
        .BANK_NUM(BANK_NUM), .ADDR_WIDTH(BBUF_ADDR_W), .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    ) u_recv (
        .clk(clk), .rst_n(rst_n), .start(start),
        .cfg_b_total_beats(total_beats), .done(done),
        .rd_resp_vld(rd_resp_vld), .rd_resp_rdy(rd_resp_rdy), .rd_resp_pd(rd_resp_pd),
        .bbuf_wr_en(bbuf_wr_en), .bbuf_wr_addr(bbuf_wr_addr), .bbuf_wr_dat(bbuf_wr_dat)
    );

endmodule