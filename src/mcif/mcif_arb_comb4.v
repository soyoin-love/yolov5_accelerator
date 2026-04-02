//轮询算法
module mcif_arb_comb4
(
	input [1:0]cur_arb_id,
	input [3:0]arb_req,
	input arb_en,
	output reg [1:0]nxt_arb_id
);


always @(*)
begin
	if(arb_en)
	begin
		case(cur_arb_id)
			2'd0:  //如果当前是port0
				case(1'b1)  //优先级1 ->  2  ->  3  ->  0
					arb_req[1]:nxt_arb_id=2'd1;
					arb_req[2]:nxt_arb_id=2'd2;
					arb_req[3]:nxt_arb_id=2'd3;
					arb_req[0]:nxt_arb_id=2'd0;
					default:nxt_arb_id=2'd0;
				endcase
			2'd1:
				case(1'b1)
					arb_req[2]:nxt_arb_id=2'd2;
					arb_req[3]:nxt_arb_id=2'd3;
					arb_req[0]:nxt_arb_id=2'd0;
					arb_req[1]:nxt_arb_id=2'd1;
					default:nxt_arb_id=2'd1;
				endcase
			2'd2:
				case(1'b1)
					arb_req[3]:nxt_arb_id=2'd3;
					arb_req[0]:nxt_arb_id=2'd0;
					arb_req[1]:nxt_arb_id=2'd1;
					arb_req[2]:nxt_arb_id=2'd2;
					default:nxt_arb_id=2'd2;
				endcase
			2'd3:
				case(1'b1)
					arb_req[0]:nxt_arb_id=2'd0;
					arb_req[1]:nxt_arb_id=2'd1;
					arb_req[2]:nxt_arb_id=2'd2;
					arb_req[3]:nxt_arb_id=2'd3;
					default:nxt_arb_id=2'd3;
				endcase
			default:nxt_arb_id=2'd0;
		endcase
	end
	else   //arb_en为低电平,则保持ID不变,因为握手没有成功
		nxt_arb_id=cur_arb_id;
end

endmodule

