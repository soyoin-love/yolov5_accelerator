`timescale 1ns / 1ps

module w_cdma_send_cmd #(
    parameter MAX_BURST_LEN      = 16,
    parameter LOG2_MAX_BURST_LEN = 4
)(
    input  wire                                 clk,
    input  wire                                 rst_n,
    input  wire                                 start,
    
    // [新配置] 总共需要请求的 AXI Beats 数量
    input  wire [27:0]                          cfg_wt_total_beats, 
    input  wire [31:0]                          cfg_wt_base_addr,  
    
    input  wire                                 wbuf_can_write,

    output wire                                 rd_req_vld,
    input  wire                                 rd_req_rdy,
    output wire [31 + LOG2_MAX_BURST_LEN:0]     rd_req_pd
);

    wire [27:0] total_bursts = (cfg_wt_total_beats + MAX_BURST_LEN - 1) >> LOG2_MAX_BURST_LEN;

    reg [27:0] burst_cnt;
    wire burst_is_last = (burst_cnt == total_bursts - 1);
    
    wire cmd_handshake = rd_req_vld && rd_req_rdy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) burst_cnt <= 0;
        else if (cmd_handshake) begin
            if (burst_is_last) burst_cnt <= 0;
            else burst_cnt <= burst_cnt + 1'b1;
        end
    end

    reg working;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) working <= 1'b0;
        else if (start) working <= 1'b1;
        else if (cmd_handshake && burst_is_last) working <= 1'b0;
    end

    assign rd_req_vld = working && wbuf_can_write;

    wire [31:0] cmd_addr = cfg_wt_base_addr + (burst_cnt << (4 + LOG2_MAX_BURST_LEN));
    
    // 如果是最后一次请求，判断余数
    wire [LOG2_MAX_BURST_LEN-1:0] cmd_len = 
        burst_is_last ? (cfg_wt_total_beats[LOG2_MAX_BURST_LEN-1:0] - 1'b1) : (MAX_BURST_LEN - 1);

    assign rd_req_pd = {cmd_len, cmd_addr};

endmodule