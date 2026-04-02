/*
写混合包(129bit)形式:
1.最高位为1代表命令包,为0代表数据包
2.为数据包时,低128bit作为数据
3.为命令包时,  bit40为1代表需要告诉DMA完全写完  bit39-32代表beat个数  bit31-0代表地址

*/
module mcif_wr_4w #
(
	parameter C_M_AXI_ID_WIDTH=2,
	parameter LOG2_AXI_MAX_BURST_LEN=8,  // 对应突发长度256 (2^8=256)
	parameter AXI_DATA_WIDTH=128           // AXI总线宽度128bit
)
(
	input clk,
	input rst_n,

	//////////////////////////////////////////////////
	input wr_req_vld0,
	output wr_req_rdy0,
	input [AXI_DATA_WIDTH+1-1:0]wr_req_pd0,   //129bit混合包.MSB=1则写命令包  MSB=0则写数据包
	output wr_rsp_complete0,
	//////////////////////////////////////////////////
	input wr_req_vld1,
	output wr_req_rdy1,
	input [AXI_DATA_WIDTH+1-1:0]wr_req_pd1,
	output wr_rsp_complete1,
	//////////////////////////////////////////////////
	input wr_req_vld2,
	output wr_req_rdy2,
	input [AXI_DATA_WIDTH+1-1:0]wr_req_pd2,
	output wr_rsp_complete2,
	//////////////////////////////////////////////////
	input wr_req_vld3,
	output wr_req_rdy3,
	input [AXI_DATA_WIDTH+1-1:0]wr_req_pd3,
	output wr_rsp_complete3,
	//////////////////////////////////////////////////
	//AW channel
	output [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
	output [32-1 : 0] M_AXI_AWADDR,
	output [LOG2_AXI_MAX_BURST_LEN-1 : 0] M_AXI_AWLEN,
	output [2 : 0] M_AXI_AWSIZE,//=clogb2((AXI_DATA_WIDTH/8)-1);
	output [1 : 0] M_AXI_AWBURST,//=2'b01;
	output  M_AXI_AWLOCK,//1'b0;
	output [3 : 0] M_AXI_AWCACHE,//=4'b0010
	output [2 : 0] M_AXI_AWPROT,//=3'h0;
	output [3 : 0] M_AXI_AWQOS,//=4'h0;
	output  M_AXI_AWVALID,
	input  M_AXI_AWREADY,
	
	//Wr channel
	output [AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
	output [AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output  M_AXI_WLAST,
	output  M_AXI_WVALID,
	input  M_AXI_WREADY,
    
    //Bersp   channel
	input [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,//ignore
	input [1 : 0] M_AXI_BRESP,//ignore
	input  M_AXI_BVALID,//Bvalid and Bread means a a write response.
	output  M_AXI_BREADY//Bvalid and Bread means a a write response.
);

// function integer clogb2 (input integer bit_depth);              
// begin                                                           
// for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
//     bit_depth = bit_depth >> 1;                                 
// end                                                           
// endfunction

function integer clogb2 (input integer bit_depth);
    integer temp; // 定义一个局部变量
    begin
        temp = bit_depth;
        // 使用局部变量 temp 进行计算，不要直接修改 bit_depth
        for(clogb2=0; temp>0; clogb2=clogb2+1) begin
            temp = temp >> 1;
        end
    end
endfunction

wire wr_cmd_fifo_0_data_in_rdy;
wire wr_cmd_fifo_1_data_in_rdy;
wire wr_cmd_fifo_2_data_in_rdy;
wire wr_cmd_fifo_3_data_in_rdy;

wire wr_dat_fifo_0_data_in_rdy;
wire wr_dat_fifo_1_data_in_rdy;
wire wr_dat_fifo_2_data_in_rdy;
wire wr_dat_fifo_3_data_in_rdy;

wire wr_cmd_fifo_0_data_out_vld;
wire wr_cmd_fifo_1_data_out_vld;
wire wr_cmd_fifo_2_data_out_vld;
wire wr_cmd_fifo_3_data_out_vld;

wire wr_cmd_fifo_0_data_out_rdy;
wire wr_cmd_fifo_1_data_out_rdy;
wire wr_cmd_fifo_2_data_out_rdy;
wire wr_cmd_fifo_3_data_out_rdy;

wire [LOG2_AXI_MAX_BURST_LEN+32+1-1:0]wr_cmd_fifo_0_data_out;
wire [LOG2_AXI_MAX_BURST_LEN+32+1-1:0]wr_cmd_fifo_1_data_out;
wire [LOG2_AXI_MAX_BURST_LEN+32+1-1:0]wr_cmd_fifo_2_data_out;
wire [LOG2_AXI_MAX_BURST_LEN+32+1-1:0]wr_cmd_fifo_3_data_out;

wire wr_dat_fifo_0_data_out_vld;
wire wr_dat_fifo_1_data_out_vld;
wire wr_dat_fifo_2_data_out_vld;
wire wr_dat_fifo_3_data_out_vld;

wire wr_dat_fifo_0_data_out_rdy;
wire wr_dat_fifo_1_data_out_rdy;
wire wr_dat_fifo_2_data_out_rdy;
wire wr_dat_fifo_3_data_out_rdy;

wire [AXI_DATA_WIDTH-1:0]wr_dat_fifo_0_data_out;
wire [AXI_DATA_WIDTH-1:0]wr_dat_fifo_1_data_out;
wire [AXI_DATA_WIDTH-1:0]wr_dat_fifo_2_data_out;
wire [AXI_DATA_WIDTH-1:0]wr_dat_fifo_3_data_out;

//为命令包与数据包例化fifo,根据MSB决定混合包放入哪一个fifo
hs_pipe #
(
	.DATA_WIDTH(LOG2_AXI_MAX_BURST_LEN+32+1),
	.PIPE_DEPTH(4)
)u_wr_cmd_fifo_0
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld0&wr_req_pd0[AXI_DATA_WIDTH]),  //MSB为1则是命令包  
	.data_in(wr_req_pd0[LOG2_AXI_MAX_BURST_LEN+32+1-1:0]),
	.data_in_rdy(wr_cmd_fifo_0_data_in_rdy),

	.data_out_vld(wr_cmd_fifo_0_data_out_vld),
	.data_out(wr_cmd_fifo_0_data_out),
	.data_out_rdy(wr_cmd_fifo_0_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(AXI_DATA_WIDTH),
	.PIPE_DEPTH(64),
	.PROG_FULL_THRESH(60)
)u_wr_dat_fifo_0
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld0&(~wr_req_pd0[AXI_DATA_WIDTH])),
	.data_in(wr_req_pd0[AXI_DATA_WIDTH-1:0]),
	.data_in_rdy(wr_dat_fifo_0_data_in_rdy),

	.data_out_vld(wr_dat_fifo_0_data_out_vld),
	.data_out(wr_dat_fifo_0_data_out),
	.data_out_rdy(wr_dat_fifo_0_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(LOG2_AXI_MAX_BURST_LEN+32+1),
	.PIPE_DEPTH(4)
)u_wr_cmd_fifo_1
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld1&wr_req_pd1[AXI_DATA_WIDTH]),
	.data_in(wr_req_pd1[LOG2_AXI_MAX_BURST_LEN+32+1-1:0]),
	.data_in_rdy(wr_cmd_fifo_1_data_in_rdy),

	.data_out_vld(wr_cmd_fifo_1_data_out_vld),
	.data_out(wr_cmd_fifo_1_data_out),
	.data_out_rdy(wr_cmd_fifo_1_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(AXI_DATA_WIDTH),
	.PIPE_DEPTH(64),
	.PROG_FULL_THRESH(60)
)u_wr_dat_fifo_1
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld1&(~wr_req_pd1[AXI_DATA_WIDTH])),
	.data_in(wr_req_pd1[AXI_DATA_WIDTH-1:0]),
	.data_in_rdy(wr_dat_fifo_1_data_in_rdy),

	.data_out_vld(wr_dat_fifo_1_data_out_vld),
	.data_out(wr_dat_fifo_1_data_out),
	.data_out_rdy(wr_dat_fifo_1_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(LOG2_AXI_MAX_BURST_LEN+32+1),
	.PIPE_DEPTH(4)
)u_wr_cmd_fifo_2
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld2&wr_req_pd2[AXI_DATA_WIDTH]),
	.data_in(wr_req_pd2[LOG2_AXI_MAX_BURST_LEN+32+1-1:0]),
	.data_in_rdy(wr_cmd_fifo_2_data_in_rdy),

	.data_out_vld(wr_cmd_fifo_2_data_out_vld),
	.data_out(wr_cmd_fifo_2_data_out),
	.data_out_rdy(wr_cmd_fifo_2_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(AXI_DATA_WIDTH),
	.PIPE_DEPTH(64),
	.PROG_FULL_THRESH(60)
)u_wr_dat_fifo_2
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld2&(~wr_req_pd2[AXI_DATA_WIDTH])),
	.data_in(wr_req_pd2[AXI_DATA_WIDTH-1:0]),
	.data_in_rdy(wr_dat_fifo_2_data_in_rdy),

	.data_out_vld(wr_dat_fifo_2_data_out_vld),
	.data_out(wr_dat_fifo_2_data_out),
	.data_out_rdy(wr_dat_fifo_2_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(LOG2_AXI_MAX_BURST_LEN+32+1),
	.PIPE_DEPTH(4)
)u_wr_cmd_fifo_3
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld3&wr_req_pd3[AXI_DATA_WIDTH]),
	.data_in(wr_req_pd3[LOG2_AXI_MAX_BURST_LEN+32+1-1:0]),
	.data_in_rdy(wr_cmd_fifo_3_data_in_rdy),

	.data_out_vld(wr_cmd_fifo_3_data_out_vld),
	.data_out(wr_cmd_fifo_3_data_out),
	.data_out_rdy(wr_cmd_fifo_3_data_out_rdy)
);

hs_pipe #
(
	.DATA_WIDTH(AXI_DATA_WIDTH),
	.PIPE_DEPTH(64),
	.PROG_FULL_THRESH(60)
)u_wr_dat_fifo_3
(
	.clk(clk),
	.rst_n(rst_n),

	.data_in_vld(wr_req_vld3&(~wr_req_pd3[AXI_DATA_WIDTH])),
	.data_in(wr_req_pd3[AXI_DATA_WIDTH-1:0]),
	.data_in_rdy(wr_dat_fifo_3_data_in_rdy),

	.data_out_vld(wr_dat_fifo_3_data_out_vld),
	.data_out(wr_dat_fifo_3_data_out),
	.data_out_rdy(wr_dat_fifo_3_data_out_rdy)
);

//根据混合包标志位与数据fifo/命令fifo准备信号来决定准备信号
assign wr_req_rdy0=wr_req_pd0[AXI_DATA_WIDTH]?wr_cmd_fifo_0_data_in_rdy:wr_dat_fifo_0_data_in_rdy;
assign wr_req_rdy1=wr_req_pd1[AXI_DATA_WIDTH]?wr_cmd_fifo_1_data_in_rdy:wr_dat_fifo_1_data_in_rdy;
assign wr_req_rdy2=wr_req_pd2[AXI_DATA_WIDTH]?wr_cmd_fifo_2_data_in_rdy:wr_dat_fifo_2_data_in_rdy;
assign wr_req_rdy3=wr_req_pd3[AXI_DATA_WIDTH]?wr_cmd_fifo_3_data_in_rdy:wr_dat_fifo_3_data_in_rdy;

wire wr_arb_req_0=wr_cmd_fifo_0_data_out_vld;// & (wr_cmd_fifo_0_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]<port0_wr_dat_cnt);
wire wr_arb_req_1=wr_cmd_fifo_1_data_out_vld;// & (wr_cmd_fifo_1_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]<port1_wr_dat_cnt);
wire wr_arb_req_2=wr_cmd_fifo_2_data_out_vld;// & (wr_cmd_fifo_2_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]<port2_wr_dat_cnt);
wire wr_arb_req_3=wr_cmd_fifo_3_data_out_vld;// & (wr_cmd_fifo_3_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]<port3_wr_dat_cnt);

wire wr_arb_gnt_0;
wire wr_arb_gnt_1;
wire wr_arb_gnt_2;
wire wr_arb_gnt_3;

assign wr_cmd_fifo_0_data_out_rdy=wr_arb_gnt_0&M_AXI_AWREADY;
assign wr_cmd_fifo_1_data_out_rdy=wr_arb_gnt_1&M_AXI_AWREADY;
assign wr_cmd_fifo_2_data_out_rdy=wr_arb_gnt_2&M_AXI_AWREADY;
assign wr_cmd_fifo_3_data_out_rdy=wr_arb_gnt_3&M_AXI_AWREADY;

wire wlen_wid_noposted_fifo_full;
wire wlen_wid_noposted_fifo_empty;
wire [LOG2_AXI_MAX_BURST_LEN+4+1-1:0]wlen_wid_noposted_fifo_data_out;

//轮询仲裁cmd_fifo是否有请求,注意是命令fifo!!!
mcif_rr_arb4 u_wr_rr_arb4
(
	.clk(clk),
	.rst_n(rst_n),

	.gnt_valid(M_AXI_AWVALID),
	.gnt_ready(M_AXI_AWREADY),

	.arb_req({wr_arb_req_3,wr_arb_req_2,wr_arb_req_1,wr_arb_req_0}),
	.arb_gnt({wr_arb_gnt_3,wr_arb_gnt_2,wr_arb_gnt_1,wr_arb_gnt_0})
);

//记事本FIFO,记录放出去的写命令  写数据跟随着这个记录按顺序写进去
wire noposted_aw_ch;
fifo_dff #
(
	.DATA_WIDTH(LOG2_AXI_MAX_BURST_LEN+4+1),
	.PIPE_DEPTH(8)
)wlen_wid_noposted_fifo
(
	.clk(clk),
	.rst_n(rst_n),

	.push(M_AXI_AWVALID&M_AXI_AWREADY),   //握手成功写入
	.data_in({noposted_aw_ch,{wr_arb_gnt_3,wr_arb_gnt_2,wr_arb_gnt_1,wr_arb_gnt_0},M_AXI_AWLEN}),
    //存了   1.标记位(是否需要写完成)  2.是谁发的命令包  3.突发长度,告诉W通道何时发WLAST信号
	.full(wlen_wid_noposted_fifo_full),

	.pop(M_AXI_WLAST&M_AXI_WVALID&M_AXI_WREADY),  //当一组写命令包要求的写数据发完,此时才会出下一个通道数据
	.data_out(wlen_wid_noposted_fifo_data_out),   //注意这个wlast
	.empty(wlen_wid_noposted_fifo_empty)
);

//标记位,指示是否需要生成"写完成信号"
assign noposted_aw_ch=(wr_arb_gnt_0?wr_cmd_fifo_0_data_out[LOG2_AXI_MAX_BURST_LEN+32]:0) |
			(wr_arb_gnt_1?wr_cmd_fifo_1_data_out[LOG2_AXI_MAX_BURST_LEN+32]:0) |
			(wr_arb_gnt_2?wr_cmd_fifo_2_data_out[LOG2_AXI_MAX_BURST_LEN+32]:0) |
			(wr_arb_gnt_3?wr_cmd_fifo_3_data_out[LOG2_AXI_MAX_BURST_LEN+32]:0);

/*
零延迟旁路逻辑
平常设计都是写数据包先进fifo再读出来,这样子会有一个时钟周期延迟
此处当检测fifo为空时不进fifo直接把任务参数拿来用
均采用 A ? (B ? C : D) : E
1.FIFO不为空
    即之前任务堆积,因此必须老实用FIFO输出数据
2.FIFO空
    AWVALID说明仲裁器批了一个新地址,启动旁路模式,直接引用当前仲裁结果
    没有则没事干,输出0
*/
//记录是否需要标记位
wire noposted_data_ch=wlen_wid_noposted_fifo_empty
?(M_AXI_AWVALID?noposted_aw_ch:0)
:wlen_wid_noposted_fifo_data_out[LOG2_AXI_MAX_BURST_LEN+4];

//记录是哪个通道(4bit独热码)
wire [4-1:0]cur_wid_data_ch=wlen_wid_noposted_fifo_empty
?(M_AXI_AWVALID?{wr_arb_gnt_3,wr_arb_gnt_2,wr_arb_gnt_1,wr_arb_gnt_0}:4'b0)
:wlen_wid_noposted_fifo_data_out[LOG2_AXI_MAX_BURST_LEN+4-1:LOG2_AXI_MAX_BURST_LEN];

//记录突发长度
wire [LOG2_AXI_MAX_BURST_LEN-1:0]cur_burst_len_data_ch=wlen_wid_noposted_fifo_empty
?(M_AXI_AWVALID?M_AXI_AWLEN:0)  
:wlen_wid_noposted_fifo_data_out[LOG2_AXI_MAX_BURST_LEN-1:0];

//通道授权成功.提取地址,ID,突发长度
wire [C_M_AXI_ID_WIDTH-1:0]wid_0=wr_arb_gnt_0?0:0;
wire [C_M_AXI_ID_WIDTH-1:0]wid_1=wr_arb_gnt_1?1:0;
wire [C_M_AXI_ID_WIDTH-1:0]wid_2=wr_arb_gnt_2?2:0;
wire [C_M_AXI_ID_WIDTH-1:0]wid_3=wr_arb_gnt_3?3:0;

wire [LOG2_AXI_MAX_BURST_LEN-1:0]wlen_0=wr_arb_gnt_0?wr_cmd_fifo_0_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]:0;
wire [LOG2_AXI_MAX_BURST_LEN-1:0]wlen_1=wr_arb_gnt_1?wr_cmd_fifo_1_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]:0;
wire [LOG2_AXI_MAX_BURST_LEN-1:0]wlen_2=wr_arb_gnt_2?wr_cmd_fifo_2_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]:0;
wire [LOG2_AXI_MAX_BURST_LEN-1:0]wlen_3=wr_arb_gnt_3?wr_cmd_fifo_3_data_out[LOG2_AXI_MAX_BURST_LEN+32-1:32]:0;

wire [31:0]awaddr_0=wr_arb_gnt_0?wr_cmd_fifo_0_data_out[31:0]:32'd0;
wire [31:0]awaddr_1=wr_arb_gnt_1?wr_cmd_fifo_1_data_out[31:0]:32'd0;
wire [31:0]awaddr_2=wr_arb_gnt_2?wr_cmd_fifo_2_data_out[31:0]:32'd0;
wire [31:0]awaddr_3=wr_arb_gnt_3?wr_cmd_fifo_3_data_out[31:0]:32'd0;

//由记事本的POP通道决定写哪个数据,确保顺序无误
wire wvalid_0=(cur_wid_data_ch==4'b0001)?wr_dat_fifo_0_data_out_vld:0;
wire wvalid_1=(cur_wid_data_ch==4'b0010)?wr_dat_fifo_1_data_out_vld:0;
wire wvalid_2=(cur_wid_data_ch==4'b0100)?wr_dat_fifo_2_data_out_vld:0;
wire wvalid_3=(cur_wid_data_ch==4'b1000)?wr_dat_fifo_3_data_out_vld:0;

wire [AXI_DATA_WIDTH-1:0]wdata_0=(cur_wid_data_ch==4'b0001)?wr_dat_fifo_0_data_out:0;
wire [AXI_DATA_WIDTH-1:0]wdata_1=(cur_wid_data_ch==4'b0010)?wr_dat_fifo_1_data_out:0;
wire [AXI_DATA_WIDTH-1:0]wdata_2=(cur_wid_data_ch==4'b0100)?wr_dat_fifo_2_data_out:0;
wire [AXI_DATA_WIDTH-1:0]wdata_3=(cur_wid_data_ch==4'b1000)?wr_dat_fifo_3_data_out:0;

assign wr_dat_fifo_0_data_out_rdy=(cur_wid_data_ch==4'b0001)&M_AXI_WREADY;
assign wr_dat_fifo_1_data_out_rdy=(cur_wid_data_ch==4'b0010)&M_AXI_WREADY;
assign wr_dat_fifo_2_data_out_rdy=(cur_wid_data_ch==4'b0100)&M_AXI_WREADY;
assign wr_dat_fifo_3_data_out_rdy=(cur_wid_data_ch==4'b1000)&M_AXI_WREADY;

assign wr_rsp_complete0=noposted_data_ch & (M_AXI_WLAST&M_AXI_WVALID&M_AXI_WREADY) & (cur_wid_data_ch==4'b0001);
assign wr_rsp_complete1=noposted_data_ch & (M_AXI_WLAST&M_AXI_WVALID&M_AXI_WREADY) & (cur_wid_data_ch==4'b0010);
assign wr_rsp_complete2=noposted_data_ch & (M_AXI_WLAST&M_AXI_WVALID&M_AXI_WREADY) & (cur_wid_data_ch==4'b0100);
assign wr_rsp_complete3=noposted_data_ch & (M_AXI_WLAST&M_AXI_WVALID&M_AXI_WREADY) & (cur_wid_data_ch==4'b1000);

reg [LOG2_AXI_MAX_BURST_LEN-1:0]wlen_cnt;
always @(posedge clk or negedge rst_n)                                                                                                     
if(~rst_n)
	wlen_cnt<=0;
else
	if(M_AXI_WVALID&M_AXI_WREADY)  //已经写入的wlen计数
	begin
		if(M_AXI_WLAST)
			wlen_cnt<=0;
		else
			wlen_cnt<=wlen_cnt+1;
	end

reg axi_bready;
always @(posedge clk or negedge rst_n)                                                                                                     
if(~rst_n)                                                           
	axi_bready<=1'b0;                                                                                                                          
else
	if(M_AXI_BVALID&&~axi_bready)  //看到ddr响应以后且自己没准备好,下一周期准备                                                                               
		axi_bready <= 1'b1;                                                                                                                                       
	else
		if(axi_bready)   //握手完成复位
			axi_bready<=1'b0;      

//AW channel
assign M_AXI_AWADDR=awaddr_0|awaddr_1|awaddr_2|awaddr_3;
assign M_AXI_AWLEN=wlen_0|wlen_1|wlen_2|wlen_3;
assign M_AXI_AWID=wid_0|wid_1|wid_2|wid_3;
//仅当  1.有人拿到授权   2.且记事本fifo有空位可以记录  才可以发送写地址
assign M_AXI_AWVALID=(wr_arb_gnt_3|wr_arb_gnt_2|wr_arb_gnt_1|wr_arb_gnt_0)&(~wlen_wid_noposted_fifo_full);

//Wr channel
assign M_AXI_WVALID=wvalid_0|wvalid_1|wvalid_2|wvalid_3;
assign M_AXI_WDATA=wdata_0|wdata_1|wdata_2|wdata_3;
assign M_AXI_WSTRB={(AXI_DATA_WIDTH/8){1'b1}};  //全有效
assign M_AXI_WLAST=M_AXI_WVALID&(wlen_cnt==cur_burst_len_data_ch);  //发到了最后一个突发数据
assign M_AXI_BREADY=axi_bready;

//////////////////////////////////////////////////

assign M_AXI_AWSIZE=clogb2((AXI_DATA_WIDTH/8)-1);
assign M_AXI_AWBURST=2'b01;
assign M_AXI_AWLOCK=1'b0;
assign M_AXI_AWCACHE=4'b0010;
assign M_AXI_AWPROT=3'h0;
assign M_AXI_AWQOS=4'h0;

endmodule