module D_FF_1bit_with_Sel
(	
	//------------------CPU INPUT------------------------//
	input  logic 	       		clk, rst_ni, enable,
	//---------------------------------------------------//
	
	//-------------D-FF-INPUT <-> OUTPUT-----------------//
	input  logic 	 				D,
	output reg 				 		Q
	//---------------------------------------------------//
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <=  0;
		end
		else begin
			if (enable) begin
				Q <= D;
			end
			else
				Q <= Q;
		end
	end
endmodule
