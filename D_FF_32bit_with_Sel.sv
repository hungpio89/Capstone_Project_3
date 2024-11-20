module D_FF_32bit_with_Sel
(	
	//------------------CPU INPUT------------------------//
	input  logic 	       	clk, rst_ni, enable,
	//---------------------------------------------------//
	
	//-------------D-FF-INPUT <-> OUTPUT-----------------//
	input  logic [ 31 :  0]	D,
	output reg 	 [ 31 :  0]	Q
	//---------------------------------------------------//
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <=  32'd0;
		end
		else begin
			if (enable) begin
				for (int i = 0; i < 32; i = i + 1) begin: assign_32_generate
					Q[i] <= D[i];
				end
			end
			else
				Q <= Q;
		end
	end
endmodule
