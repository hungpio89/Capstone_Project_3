module D_FF_64bit
(
	input  logic        		clk, rst_ni,
	input  logic 	[63:0] 	D,
	output reg 		[63:0] 	Q
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <=  0;
		end
		else begin
			Q <= Q;
		end
end
endmodule