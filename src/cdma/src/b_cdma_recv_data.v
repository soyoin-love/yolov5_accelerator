`timescale 1ns / 1ps

module b_cdma_recv_data #(
    parameter BANK_NUM       = 8,
    parameter ADDR_WIDTH     = 9,
    parameter AXI_DATA_WIDTH = 128
)(
    input  wire                               clk,
    input  wire                               rst_n,
    input  wire                               start,
    input  wire [15:0]                        cfg_b_total_beats,
    output wire                               done,

    // MCIF 读响应
    input  wire                               rd_resp_vld,
    output wire                               rd_resp_rdy,
    input  wire [AXI_DATA_WIDTH-1:0]          rd_resp_pd,

    // BBUF 写接口
    output wire [BANK_NUM-1:0]                bbuf_wr_en,
    output wire [ADDR_WIDTH-1:0]              bbuf_wr_addr,
    output wire [BANK_NUM*64-1:0]             bbuf_wr_dat
);
    reg [15:0] rx_cnt;
    wire rx_handshake = rd_resp_vld && rd_resp_rdy;

    // 由于 BBUF 很大，不设反压 
    assign rd_resp_rdy = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rx_cnt <= 0;
        else if (start) rx_cnt <= 0;
        else if (rx_handshake) rx_cnt <= rx_cnt + 1'b1;
    end

    assign done = rx_handshake && (rx_cnt == cfg_b_total_beats - 1);

    // 路由逻辑：每 4 个 AXI 拍填充一个 BBUF 地址 [cite: 566, 567]
    wire [1:0] beat_idx = rx_cnt[1:0];
    reg [7:0]  mask_comb;
    always @(*) begin
        case (beat_idx)
            2'b00: mask_comb = 8'b0000_0011;
            2'b01: mask_comb = 8'b0000_1100;
            2'b10: mask_comb = 8'b0011_0000;
            2'b11: mask_comb = 8'b1100_0000;
            default: mask_comb = 8'b0000_0000;
        endcase
    end

    assign bbuf_wr_en   = rx_handshake ? mask_comb : 8'd0;
    assign bbuf_wr_addr = rx_cnt >> 2;
    assign bbuf_wr_dat  = {4{rd_resp_pd}}; // 依靠 wr_en 掩码选择对应的 Bank

endmodule