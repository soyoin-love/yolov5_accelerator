module upsample_fifo #(
    parameter DATA_WIDTH = 128,
    parameter DEPTH_W = 10,
    parameter DEPTH_R = DEPTH_W+1,
    parameter ALMOST_FULL_THRESHOLD = 6,
    parameter ALMOST_EMPTY_THRESHOLD = 2
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // 写端口
    input  wire                     wren,
    input  wire  [DATA_WIDTH*2-1:0] wrdata,
    output wire                     full,
    output wire                     almost_full,
    
    // 读端口
    input  wire                     rden,
    output reg   [DATA_WIDTH-1:0]   rddata,
    output wire                     empty,
    output wire                     almost_empty,
    //控制逻辑
    input wire                      change_point,
    input wire   [DEPTH_R-1:0]      col_size,  //一行列数
    output wire                     not_ready_for_output
);

reg  [DATA_WIDTH-1:0] ram [0 : (1<<DEPTH_R)-1] ;

//指针拓展一位
reg [DEPTH_W:0] wr_ptr;
reg [DEPTH_R:0] rd_ptr_real;
reg [DEPTH_R:0] rd_ptr_virtual;

//读指针选择
reg  pointer_select;  //1:true  0:virtual

//写指针统一刻度
wire [DEPTH_R:0] wr_ptr_scaled;
assign  wr_ptr_scaled = {wr_ptr,1'b0};  

//写指针与两个读指针之间数据量
wire [DEPTH_R : 0] data_count_real;
wire [DEPTH_R : 0] data_count_virtual; 

//当前
//是否可以读出
//wire fifo_rd_ready;

//读写安全门限
wire wren_internal;
wire rden_internal;

//读地址
wire [DEPTH_R-1 : 0] active_rd_addr;

//=========================================================
//时序逻辑
//=========================================================
//  写数据与写指针逻辑 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wr_ptr <= 0;
    else if(wren_internal)begin
        ram[{wr_ptr[DEPTH_W-1:0],1'b0}] <= wrdata[DATA_WIDTH-1:0];
        ram[{wr_ptr[DEPTH_W-1:0],1'b1}] <= wrdata[DATA_WIDTH*2-1:DATA_WIDTH];
        wr_ptr <= wr_ptr + 1;
    end    
end

//  读数据与读指针逻辑 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rd_ptr_real <= 0;
        rd_ptr_virtual <= 0;
        rddata <= 0;
    end  else  begin
        if (change_point && pointer_select == 1'b1) begin  //换行时,虚拟指针强制回退
            rd_ptr_virtual <= rd_ptr_real - ({1'b0, col_size} << 1);
        end
        else  if(rden_internal)begin
            if(pointer_select)begin       //根据读指针使用权决定读数据
                rd_ptr_real <= rd_ptr_real +1;
            end   else  begin
                rd_ptr_virtual <= rd_ptr_virtual + 1;  
            end    
        end
        
        if(rden_internal)begin
            rddata <= ram[active_rd_addr[DEPTH_R-1:0]];
        end    
    end
end

//读指针改变
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pointer_select <= 1;   //初始为真实指针
    else if(change_point)
        pointer_select <= ~pointer_select;    
end

//=========================================================
//组合逻辑判断
//=========================================================
// 空满以及余量
assign empty = (wr_ptr_scaled == rd_ptr_real);  
assign almost_empty = (data_count_real <= ALMOST_EMPTY_THRESHOLD);

assign full = (wr_ptr_scaled[DEPTH_R] != rd_ptr_virtual[DEPTH_R]) && 
              (wr_ptr_scaled[DEPTH_R-1:1] == rd_ptr_virtual[DEPTH_R-1:1]); //highest bit differ
assign almost_full = (data_count_virtual >= ALMOST_FULL_THRESHOLD);

//数据量
assign data_count_real    = wr_ptr_scaled - rd_ptr_real;
assign data_count_virtual = wr_ptr_scaled - rd_ptr_virtual;

//安全门限
assign wren_internal = wren && !full;
//assign rden_internal = rden && !empty;
assign rden_internal = rden;  //由上层控制虚拟指针不能超过真实指针

//读取的地址
assign active_rd_addr = pointer_select ? rd_ptr_real[DEPTH_R-1:0] : rd_ptr_virtual[DEPTH_R-1:0];

//顶层是否可读
//真实指针读时，如果 empty 为 1，就不让顶层读
//虚拟指针读时，如果它追上了真实指针(即没有历史数据可读了)，就不让顶层读
assign not_ready_for_output = pointer_select ? empty : (rd_ptr_real == rd_ptr_virtual);

endmodule