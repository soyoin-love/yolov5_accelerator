
//4端口轮询仲裁器

module mcif_rr_arb4
(
	input clk,
	input rst_n,

	input gnt_valid,   //联的ARVALID
	input gnt_ready,   //联的ARREADY
	//这两个信号一起决定允不允许读出下一个cmd_fifo命令,实现"死锁"

	input [3:0]arb_req,   //fifo_x有数据时发送请求
	output [3:0]arb_gnt
);

reg [1:0]cur_arb_id;
wire [1:0]nxt_arb_id;

//允许切换仲裁逻辑
reg arb_en;   
always @(posedge clk or negedge rst_n)
if(~rst_n)
	arb_en<=1'b1;
else
	if(gnt_valid)   //1.如果当前总线上已经有有效的请求在等待
	begin
		if(gnt_ready)   //2.且下游DDR已经准备好接受(接受成功)
			arb_en<=1'b1;   //允许仲裁器切换到下一个人
		else
			arb_en<=1'b0;	//否则禁止切换.直到当前数据包发出去
	end

//核心仲裁器
mcif_arb_comb4 u_mcif_arb_comb4
(
	.cur_arb_id(cur_arb_id),
	.arb_req(arb_req),
	.arb_en(arb_en),
	.nxt_arb_id(nxt_arb_id)
);

//时钟上升沿更新
always @(posedge clk or negedge rst_n)
if(~rst_n)
	cur_arb_id<=2'd0;
else
	cur_arb_id<=nxt_arb_id;

//1.计算出的ID是1    2.且1确实发起了请求,拉高gnt[1]
assign arb_gnt[0]=(nxt_arb_id==2'd0)&arb_req[0];
assign arb_gnt[1]=(nxt_arb_id==2'd1)&arb_req[1];
assign arb_gnt[2]=(nxt_arb_id==2'd2)&arb_req[2];
assign arb_gnt[3]=(nxt_arb_id==2'd3)&arb_req[3];

endmodule
