module register_enable_only
(	
	//------------------CPU INPUT------------------------//
	input  logic 	       		clk, rst_n, enable,
	//---------------------------------------------------//
	
	//------------CUSTOM FOR ONLY PR-HRDATA--------------//
	input  logic [ 31 :  0]		D,
	output logic [ 31 :  0]		Q
	//---------------------------------------------------//
);
	
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			Q  <= 32'b0;
		end
		else begin
			case(enable)
				1'b1: begin
					Q  <= 32'b0;
				end
				1'b0: begin
					for (int i = 0; i < 32; i = i + 1) begin: assign_32_generate
						Q[i] = D[i];
					end
				end
			endcase
		end
	end
endmodule
