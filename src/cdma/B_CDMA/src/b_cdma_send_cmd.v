`timescale 1ns / 1ps

module b_cdma_send_cmd #(
    parameter MAX_BURST_LEN      = 256,
    parameter LOG2_MAX_BURST_LEN = 8
)(
    input  wire                                 clk,
    input  wire                                 rst_n,
    input  wire                                 start,
    
    // 配置
    input  wire [15:0]                          cfg_b_total_beats, 
    input  wire [31:0]                          cfg_b_base_addr,  
    
    // MCIF 请求接口
    output wire                                 rd_req_vld,
    input  wire                                 rd_req_rdy,
    output wire [31 + LOG2_MAX_BURST_LEN:0]     rd_req_pd
);
    // 计算总共需要多少次 AXI 突发 
    wire [15:0] total_bursts = (cfg_b_total_beats + MAX_BURST_LEN - 1) >> LOG2_MAX_BURST_LEN;

    reg [15:0] burst_cnt;
    wire burst_is_last = (burst_cnt == total_bursts - 1);
    
    wire cmd_handshake = rd_req_vld && rd_req_rdy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) burst_cnt <= 0;
        else if (start) burst_cnt <= 0;
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

    assign rd_req_vld = working;

    // 地址累加逻辑：起始地址 + 已完成的突发次数 * 每次突发的字节数 [cite: 243]
    wire [31:0] cmd_addr = cfg_b_base_addr + (burst_cnt << (4 + LOG2_MAX_BURST_LEN));
    
    // 长度计算：最后一次取余数，其余取最大突发长度 [cite: 244]
    wire [LOG2_MAX_BURST_LEN-1:0] cmd_len = 
        burst_is_last ? (cfg_b_total_beats[LOG2_MAX_BURST_LEN-1:0] - 1'b1) : (MAX_BURST_LEN - 1);

    assign rd_req_pd = {cmd_len, cmd_addr};

endmodule