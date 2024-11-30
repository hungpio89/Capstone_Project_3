module store_inst (
	input  logic [31 : 0] store_data,
	input  logic	      sw_en, sb_en, sh_en,
	output logic [31 : 0] output_data
);
	//-------------------create signal--------------------
		logic [2:0] sel;
	//----------------------------------------------------
	
	
	//-------------------assign signal--------------------
		assign sel = {sb_en, sh_en, sw_en};
	//----------------------------------------------------

		
	always @(*) begin
		output_data  = 0;
		case(sel)
			3'b100: begin
					output_data[ 7: 0] = store_data[ 7: 0];
				for (int i = 8; i < 32; i = i + 1) begin: assign_bit_zero_extend
					output_data[i] = 0;
				end
			end
			3'b010: begin
					output_data[15: 0] = store_data[15: 0]; 
				for (int i = 16; i < 32; i = i + 1) begin: assign_bit_zero_extend
					output_data[i] = 0;
				end
			end
			3'b001: begin
                                        output_data[31: 0] = store_data[31: 0];
                        end
			default: begin 
				output_data = 0;
			end
		endcase
	end
endmodule
