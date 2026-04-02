// module hs_pipe #
// (
// 	parameter DATA_WIDTH=256,
// 	parameter PIPE_DEPTH=8
// )
// (
//     input clk,
//     input rst_n,
    
//     input data_in_vld,
//     input [DATA_WIDTH-1:0]data_in,
//     output data_in_rdy,
    
//     output data_out_vld,
//     output [DATA_WIDTH-1:0]data_out,
//     input data_out_rdy
// );

// function integer clogb2 (input integer bit_depth);              
// begin                                                           
// for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
//   bit_depth = bit_depth >> 1;                                 
// end                                                           
// endfunction

// localparam clog2_PIPE_DEPTH=clogb2(PIPE_DEPTH-1);

// reg [DATA_WIDTH-1:0]mem[PIPE_DEPTH-1:0];
// reg [clog2_PIPE_DEPTH-1:0]w_pointer;reg w_phase;
// reg [clog2_PIPE_DEPTH-1:0]r_pointer;reg r_phase;

// wire wr_en=data_in_vld&data_in_rdy;
// wire rd_en=data_out_vld&data_out_rdy;

// always @(posedge clk or negedge rst_n)
// if(~rst_n)
// begin
// 	w_phase<=1'b0;
//     w_pointer<=0;
// end  
// else
//     if(wr_en)
//     begin
//         if( w_pointer == PIPE_DEPTH-1)
//         begin
//             w_pointer<='d0;
//             w_phase <= ~w_phase;
//         end
//         else
//             w_pointer<=w_pointer+'d1;
//     end
    
// always @(posedge clk or negedge rst_n)
// if(~rst_n)
// begin
//     r_pointer<=0;
//     r_phase<=1'b0;
// end
// else
//     if(rd_en)
//     begin
//         if( r_pointer == PIPE_DEPTH-1)
//         begin
//             r_pointer<='d0;
//         		r_phase<=~r_phase;    
//         end
//         else
//             r_pointer<=r_pointer+'d1;
//     end
    
// always @(posedge clk)
// if(wr_en)
//     mem[w_pointer]<=data_in;
    
// wire [DATA_WIDTH-1:0]data_out_c=mem[r_pointer];

// assign data_out=data_out_c;//rd_en?data_out_c:data_out_r;
// wire empty=(w_pointer==r_pointer)&&(w_phase^~r_phase);
// wire full=(w_pointer==r_pointer)&&(w_phase^r_phase);
// assign data_out_vld=~empty;
// assign data_in_rdy=~full;

// endmodule

module hs_pipe #
(
    parameter DATA_WIDTH=256,
    parameter PIPE_DEPTH=8,
    parameter PROG_FULL_THRESH=0 // 新增：提前反压阈值 (0代表不开启，兼容旧模块)
)
(
    input clk,
    input rst_n,
    
    input data_in_vld,
    input [DATA_WIDTH-1:0]data_in,
    output data_in_rdy,
    
    output data_out_vld,
    output [DATA_WIDTH-1:0]data_out,
    input data_out_rdy
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
  bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction

localparam clog2_PIPE_DEPTH=clogb2(PIPE_DEPTH-1);

reg [DATA_WIDTH-1:0]mem[PIPE_DEPTH-1:0];
reg [clog2_PIPE_DEPTH-1:0]w_pointer;reg w_phase;
reg [clog2_PIPE_DEPTH-1:0]r_pointer;reg r_phase;

// -----------------------------------------------------------------
// 核心修改区：计算余量并解耦 Ready 与 Write Enable
// -----------------------------------------------------------------
wire empty = (w_pointer==r_pointer)&&(w_phase^~r_phase);
wire full  = (w_pointer==r_pointer)&&(w_phase^r_phase);

// 1. 计算当前 FIFO 内积压的数据个数
wire [31:0] data_cnt = (w_phase == r_phase) ? 
                       (w_pointer - r_pointer) : 
                       (PIPE_DEPTH - r_pointer + w_pointer);

// 2. 产生提前反压信号 (prog_full)
wire prog_full = (PROG_FULL_THRESH > 0 && PROG_FULL_THRESH < PIPE_DEPTH) ? 
                 (data_cnt >= PROG_FULL_THRESH) : full;

// 3. 对外发出的信号
assign data_in_rdy = ~prog_full;    // 【修改】向上游的 Ready 用 prog_full 提前踩刹车
assign data_out_vld = ~empty;       // 向下游的 Valid 保持不变

// 4. 内部真实的读写使能
wire rd_en = data_out_vld & data_out_rdy; // 【修复】补回缺失的读使能定义
wire wr_en = data_in_vld & (~full);       // 【修改】真实的写使能用 full 兜底，接收飞在天上的数据
// -----------------------------------------------------------------

always @(posedge clk or negedge rst_n)
if(~rst_n)
begin
    w_phase<=1'b0;
    w_pointer<=0;
end  
else
    if(wr_en)
    begin
        if( w_pointer == PIPE_DEPTH-1)
        begin
            w_pointer<='d0;
            w_phase <= ~w_phase;
        end
        else
            w_pointer<=w_pointer+'d1;
    end
    
always @(posedge clk or negedge rst_n)
if(~rst_n)
begin
    r_pointer<=0;
    r_phase<=1'b0;
end
else
    if(rd_en)
    begin
        if( r_pointer == PIPE_DEPTH-1)
        begin
            r_pointer<='d0;
            r_phase<=~r_phase;    
        end
        else
            r_pointer<=r_pointer+'d1;
    end
    
always @(posedge clk)
if(wr_en)
    mem[w_pointer]<=data_in;
    
wire [DATA_WIDTH-1:0]data_out_c=mem[r_pointer];
assign data_out=data_out_c;

endmodule