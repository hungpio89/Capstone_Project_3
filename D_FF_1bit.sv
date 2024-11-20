module D_FF_1bit
(	
	//------------------CPU INPUT------------------------//
	input  logic 	       		clk, rst_ni,
	//---------------------------------------------------//
	
	//-------------D-FF-INPUT <-> OUTPUT-----------------//
	input  logic 	 			D,
	output reg 				 	Q
	//---------------------------------------------------//
);
	always_ff @(posedge clk or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <=  0;
		end
		else begin
			Q  <=  D;
		end
	end
endmodule
