module load_inst (
	input  logic [31 : 0] load_data,
	input  logic	      lw_en, lb_en, lh_en, lhu_en, lbu_en,
	output logic [31 : 0] output_data
);
	//-------------------create signal--------------------
		logic [4:0] sel;
	//----------------------------------------------------
	
	
	//-------------------assign signal--------------------
		assign sel = {lb_en, lh_en, lhu_en, lbu_en, lw_en};
	//----------------------------------------------------
	
	
	always @(*) begin
		output_data  = 0;
		case(sel)
			5'b10000: begin						// load byte
					output_data[ 7: 0] = load_data[ 7: 0];
				for (int i = 8; i < 32; i = i + 1) begin: assign_bit_signed_extend
					output_data[i] = load_data[7];
				end
			end
			5'b01000: begin						// load half word
					output_data[15: 0] = load_data[15: 0];
				for (int i = 16; i < 32; i = i + 1) begin: assign_bit_signed_extend
					output_data[i] = load_data[15];
				end
			end
			5'b00100: begin
					output_data[15: 0] = load_data[15: 0];	// load half word unsigned
				for (int i = 16; i < 32; i = i + 1) begin: assign_bit_zero_extend
					output_data[i] = 0;
				end
			end
			5'b00010: begin
					output_data[ 7: 0] = load_data[ 7: 0];	// load byte unsigned
				for (int i = 8; i < 32; i = i + 1) begin: assign_bit_zero_extend
					output_data[i] = 0;
				end
			end
			5'b00001: begin
                                        output_data[31: 0] = load_data[31: 0];  // load word 
                        end
			default: begin 
				output_data = 0;
			end
		endcase
	end
endmodule

