module fifo_dff #
(
	parameter DATA_WIDTH=256,
	parameter PIPE_DEPTH=8
)
(
	input clk,
	input rst_n,

	input push,
	input [DATA_WIDTH-1:0]data_in,
	output full,

	input pop,
	output [DATA_WIDTH-1:0]data_out,
	output empty
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

wire wr_en=push;
wire rd_en=pop;

always @(posedge clk or negedge rst_n)
if(~rst_n)
begin
	w_phase<=1'b0;
    w_pointer<=0;
end  
else
    if(wr_en)
    begin
        if(w_pointer == PIPE_DEPTH-1)
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
        if(r_pointer == PIPE_DEPTH-1)
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

assign data_out=data_out_c;//rd_en?data_out_c:data_out_r;
assign empty=(w_pointer==r_pointer)&&(w_phase^~r_phase);
assign full=(w_pointer==r_pointer)&&(w_phase^r_phase);

endmodule

