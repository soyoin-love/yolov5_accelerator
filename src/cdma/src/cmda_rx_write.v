`timescale 1ns / 1ps

module cdma_rx_write #(
    parameter TK_IN = 8,
    parameter N     = 8
)(
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       start,

    // 配置信号
    input  wire [15:0]                cfg_width,
    input  wire [15:0]                cfg_ch_groups,
    input  wire [15:0]                cfg_height,

    // MCIF 接收接口
    input  wire                       mcif_rx_vld,
    input  wire [2*TK_IN*N-1:0]       mcif_rx_dat, // 128-bit (2个像素)
    output wire                       mcif_rx_rdy,

    // CBUF 写入接口 (与 cbuf_top 对接)
    output reg                      wr_en,
    output reg [15:0]               wr_row,
    output reg [15:0]               wr_col,
    output reg [15:0]               wr_ch_grp,
    output reg [2*TK_IN*N-1:0]      wr_dat,
    output reg                      wr_row_done
    
);

    // 内部坐标寄存器
    reg [15:0] rx_row;
    reg [15:0] rx_col;
    reg [15:0] rx_ch_grp;
    // ==========================================
    // 1. 定义进位/结束标志信号 (辅助逻辑)
    // ==========================================

    wire  mcif_rx_ack = mcif_rx_vld &&  mcif_rx_rdy;//握手成功

    // 当前节拍是这一行（针对当前通道组）的最后一个像素块
    //wire col_last    = mcif_rx_ack && (rx_col >= cfg_width - 2);

    
    // 修正逻辑（通过加法规避减法下溢）：
    wire col_last = mcif_rx_ack && (rx_col + 16'd2 >= cfg_width);
    // 当前节拍是当前行所有通道组都传输完毕的时刻,也是一行写完信号
    wire ch_grp_last = col_last && (rx_ch_grp == cfg_ch_groups - 1);

    reg [15:0] cfg_height_m1;
    always @(posedge clk) begin
        if (start) cfg_height_m1 <= cfg_height - 1'b1;
    end

    // 这样 done 信号的比较就变成了两个寄存器值的比对，速度飞快
    wire done = (rx_row == cfg_height_m1) && ch_grp_last;

    //wire done = (rx_row == cfg_height - 1)  && ch_grp_last;  //全部写完

    // 直接透传数据和使能
    // assign wr_dat = mcif_rx_dat;
    // assign wr_en  = mcif_rx_vld;
    
    // 透传坐标
    // assign wr_row    = rx_row;
    // assign wr_col    = rx_col;
    // assign wr_ch_grp = rx_ch_grp;

    //打一拍输出
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_row <= 'd0;
            wr_col <= 'd0;
            wr_ch_grp <= 'd0;
            wr_row_done <= 'd0;
        end
        else begin
            wr_row <= rx_row;
            wr_col <= rx_col;
            wr_ch_grp <= rx_ch_grp;
            wr_row_done   <= ch_grp_last;
        end
    end    

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            wr_dat <= 'd0;
            wr_en  <= 'd0;
        end
        else begin
            wr_dat <= mcif_rx_dat;
            wr_en  <= mcif_rx_ack;
        end
    end   

    // ==========================================
    // 2. 列计数器 (最小量级：Pixel Beat)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_col <= 16'd0;
        end else if (mcif_rx_ack) begin
            if (col_last)
                rx_col <= 16'd0;
            else
                rx_col <= rx_col + 2; // 一次处理 2 个像素
        end
    end


    // ==========================================
    // 3. 通道组计数器 (中间量级：Channel Group)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_ch_grp <= 16'd0;
        end else if (col_last) begin
            if (rx_ch_grp == cfg_ch_groups - 1)
                rx_ch_grp <= 16'd0;
            else
                rx_ch_grp <= rx_ch_grp + 1;
        end
    end


    // ==========================================
    // 4. 行计数器 (最大量级：Row)
    // ==========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || start) begin
            rx_row <= 16'd0;
        end else if (ch_grp_last) begin
            rx_row <= rx_row + 1;
        end
    end

reg working ;
always @(posedge clk or negedge rst_n)
if(~rst_n)
	working<=1'b0;
else
	if(start)
		working<=1'b1;
	else
		if(done)
			working<=1'b0;

assign mcif_rx_rdy=working;    



endmodule