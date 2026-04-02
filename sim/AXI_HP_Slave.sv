`include "../defines.vh"


module AXI_HP_Slave #
(
	parameter integer BASE_ADDR=32'h0000_0000,
	parameter integer C_S_AXI_ID_WIDTH	= 2,
	parameter integer C_S_AXI_DATA_WIDTH	= `DATABUS2MEM_WIDTH,
	parameter integer C_S_AXI_ADDR_WIDTH	= `AXI_ADDR_WIDTH
)
(
	input wire  S_AXI_ACLK,
	input wire  S_AXI_ARESETN,
	input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
	input wire [7 : 0] S_AXI_AWLEN,
	input wire [2 : 0] S_AXI_AWSIZE,
	input wire [1 : 0] S_AXI_AWBURST,
	input wire  S_AXI_AWLOCK,
	input wire [3 : 0] S_AXI_AWCACHE,
	input wire [2 : 0] S_AXI_AWPROT,
	input wire [3 : 0] S_AXI_AWQOS,
	input wire [3 : 0] S_AXI_AWREGION,
	input wire  S_AXI_AWVALID,
	output wire  S_AXI_AWREADY,
	input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
	input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input wire  S_AXI_WLAST,
	input wire  S_AXI_WVALID,
	output wire  S_AXI_WREADY,
	output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
	output wire [1 : 0] S_AXI_BRESP,
	output wire  S_AXI_BVALID,
	input wire  S_AXI_BREADY,
	input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
	input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
	input wire [7 : 0] S_AXI_ARLEN,
	input wire [2 : 0] S_AXI_ARSIZE,
	input wire [1 : 0] S_AXI_ARBURST,
	input wire  S_AXI_ARLOCK,
	input wire [3 : 0] S_AXI_ARCACHE,
	input wire [2 : 0] S_AXI_ARPROT,
	input wire [3 : 0] S_AXI_ARQOS,
	input wire  S_AXI_ARVALID,
	output wire  S_AXI_ARREADY,
	output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
	output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
	output wire [1 : 0] S_AXI_RRESP,
	output wire  S_AXI_RLAST,
	output wire  S_AXI_RVALID,
	input wire  S_AXI_RREADY
);
//稀疏数组
reg /*sparse*/ [`MEM_WIDTH-1:0] memory[`MEM_SIZE-1:0];  //模拟ddr芯片

localparam access_time=`DATABUS2MEM_WIDTH/`MEM_WIDTH;//512/32=16  axi一拍对应多少内存字
localparam numbytes=`MEM_WIDTH/8;   //内存一个字的字节数

//写函数
function WriteMem(input logic[C_S_AXI_ADDR_WIDTH-1 : 0] addr,input logic[C_S_AXI_DATA_WIDTH-1 : 0] data);
begin
	//$display("WriteMem:addr=%0x,data=%0x",addr,data);
	for(int i=0;i<access_time;i=i+1)
	begin
		if(S_AXI_WSTRB[i*numbytes]) memory[(addr-BASE_ADDR)/numbytes+i][7:0]=data>>(`MEM_WIDTH*i);
		if(S_AXI_WSTRB[i*numbytes+1]) memory[(addr-BASE_ADDR)/numbytes+i][15:8]=data>>(`MEM_WIDTH*i+8);
		if(S_AXI_WSTRB[i*numbytes+2]) memory[(addr-BASE_ADDR)/numbytes+i][23:16]=data>>(`MEM_WIDTH*i+16);
		if(S_AXI_WSTRB[i*numbytes+3]) memory[(addr-BASE_ADDR)/numbytes+i][31:24]=data>>(`MEM_WIDTH*i+24);
		//memory[(addr-BASE_ADDR)/numbytes+i]=data>>(`MEM_WIDTH*i);
		//$display("write_memory[%d]",(addr-BASE_ADDR)/numbytes+i); 
	end
end
endfunction
//读函数
logic[C_S_AXI_DATA_WIDTH-1 : 0] read_data;	
function logic[C_S_AXI_DATA_WIDTH-1 : 0] ReadMem(input logic[C_S_AXI_ADDR_WIDTH-1 : 0] addr);
begin
	for(int i=0;i<access_time;i=i+1)
	begin
		read_data={memory[(addr-BASE_ADDR)/numbytes+i],read_data[C_S_AXI_DATA_WIDTH-1:`MEM_WIDTH]};
	  	//$display("read memory[%d]=%0x,read_data=%0x",(addr-32'h8000_0000)/numbytes+i,memory[(addr-32'h8000_0000)/numbytes+i],read_data);
	end
	//$display("ReadMem:addr=%0x,data=%0x",addr,read_data);
	return read_data;
end
endfunction

reg axi_awready;
reg axi_wready;
reg aw_recved;
bit [31:0]awaddr;
bit [7:0]awlen;

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
if(~S_AXI_ARESETN)
begin
	axi_awready<=1'b0;
	axi_wready<=1'b0;
	aw_recved<=1'b0;
end
else
	if(~aw_recved & S_AXI_AWVALID & ~axi_awready)
	begin
		axi_awready<=1'b1;
	end
	else
	begin
		axi_awready<=1'b0;
		if(S_AXI_WVALID & S_AXI_WREADY& S_AXI_WLAST)
		begin
			aw_recved<=1'b0;
			axi_wready<=1'b0;
		end
	end

reg [C_S_AXI_ID_WIDTH-1:0]bid;
reg [7:0]wcnt;
always @(posedge S_AXI_ACLK)
if(S_AXI_AWVALID&axi_awready)
begin
	awaddr<=S_AXI_AWADDR;
	awlen<=S_AXI_AWLEN;
	aw_recved<=1'b1;
	axi_wready<=1'b1;
	wcnt<=0;
	bid<=S_AXI_AWID;
end

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
if(~S_AXI_ARESETN)
	wcnt<=0;
else
	if(aw_recved & S_AXI_WVALID & S_AXI_WREADY)
	begin
		wcnt<=wcnt+1;
		awaddr<=awaddr+C_S_AXI_DATA_WIDTH/8;
		WriteMem(awaddr,S_AXI_WDATA);
	end

always @(posedge S_AXI_ACLK)
if(aw_recved & S_AXI_WVALID & S_AXI_WREADY)
begin
	if( ((wcnt==awlen)&(~S_AXI_WLAST)) | ((wcnt!=awlen)&(S_AXI_WLAST)) )
		$display("Error: S_AXI_WLAST is not generated correctlly!!!");
end

reg axi_arready;
reg axi_rvalid;
reg ar_recved;
wire rlast;
bit [31:0]araddr;
bit [7:0]arlen;
reg [C_S_AXI_DATA_WIDTH-1:0]rdata;

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
if(~S_AXI_ARESETN)
begin
	axi_arready<=1'b0;
	axi_rvalid<=1'b0;
	ar_recved<=1'b0;
	rdata<=0;
end
else
	if(~ar_recved & S_AXI_ARVALID & ~axi_arready)
	begin
		axi_arready<=1'b1;
	end
	else
	begin
		axi_arready<=1'b0;
		if(S_AXI_RVALID & S_AXI_RREADY & S_AXI_RLAST)
		begin
			ar_recved<=1'b0;
			axi_rvalid<=1'b0;
		end
	end

reg [C_S_AXI_ID_WIDTH-1:0]rid=0;
reg [7:0]rcnt;
always @(posedge S_AXI_ACLK)
if(axi_arready&S_AXI_ARVALID)
begin
	araddr<=S_AXI_ARADDR;
	arlen<=S_AXI_ARLEN;
	ar_recved<=1'b1;
	rdata<=ReadMem(S_AXI_ARADDR);
	axi_rvalid<=1'b1;
	rid<=S_AXI_ARID;
	rcnt<=0;
end

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
if(~S_AXI_ARESETN)
	rcnt<=0;
else
	if(ar_recved & S_AXI_RVALID & S_AXI_RREADY)
	begin
		rcnt<=rcnt+1;
		araddr<=araddr+C_S_AXI_DATA_WIDTH/8;
		rdata<=ReadMem(araddr+C_S_AXI_DATA_WIDTH/8);
	end

always @(posedge S_AXI_ACLK)
if(ar_recved & S_AXI_RVALID & S_AXI_RREADY)
begin
	if( ((rcnt==arlen)&(~rlast)) | ((rcnt!=arlen)&(rlast)) )
		$display("Error: R_AXI_WLAST is not generated correctlly!!!");
end

assign rlast=ar_recved&axi_rvalid&(rcnt==arlen);

reg bvalid;
reg [1:0]bresp;

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN)
if(~S_AXI_ARESETN)
begin
	bvalid <= 0;
	bresp <= 2'b0;
end 
else
begin    
	if (S_AXI_WREADY && S_AXI_WVALID && ~bvalid && S_AXI_WLAST)
	begin
		bvalid <= 1'b1;
		bresp  <= 2'b0; 
	end                   
	else
	begin
		if (S_AXI_BREADY && bvalid) 
		bvalid <= 1'b0; 
	end
end

assign S_AXI_AWREADY=axi_awready;
assign S_AXI_WREADY=axi_wready;

assign S_AXI_BID=bid;
assign S_AXI_BRESP=bresp;
assign S_AXI_BVALID=bvalid;

assign S_AXI_ARREADY=axi_arready;
assign S_AXI_RID=rid;
assign S_AXI_RDATA=rdata;
assign S_AXI_RRESP=2'b0;
assign S_AXI_RLAST=rlast;
assign S_AXI_RVALID=axi_rvalid;

endmodule
