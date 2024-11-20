module D_FF_32bit
(
	input  logic        		clk, rst_ni,
	input  logic 	[31:0] 	D,
	output reg 		[31:0] 	Q
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <= 0;
		end
		else begin
			Q  <= D ;
		end
end
endmodule
