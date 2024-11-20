module D_FF_4BIT
(
	input  logic        		   clk, rst_ni,
	input  logic 	[ 3 : 0] 	D,
	
	output reg 		[ 3 : 0] 	Q
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <= 4'b0;
		end
		else begin
			Q  <= D;
		end
	end
endmodule
