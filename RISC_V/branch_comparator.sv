module branch_comparator 
(
// Input and Output 
	// Input Logic
	input  logic [31:0] 	rs1_data,
	input  logic [31:0] 	rs2_data,
	input  			br_unsigned,
  
  // Output logic 
	output reg 			 br_equal,
	output reg 			 br_less
);

	wire w0,w1,w2,w3;
	wire diff_sign,neg_rs1;

	wire _unused_ok = &{1'b0, w3, 1'b0};
Comparator_Un	Unsigned(
	.a(rs1_data),
	.b(rs2_data),
	.a_equal_b(w0),
	.a_less_b(w1)
);

Comparator_S	Signed(
	.a(rs1_data[30: 0]),
	.b(rs2_data[30: 0]),
	.a_equal_b(w2),
	.a_less_b(w3)
);
	assign diff_sign = rs1_data[31] ^ rs2_data[31];		// Different in signed bit between rs1 and rs2
	assign neg_rs1   = rs1_data[31];			// Signed bit for rs1

	always_comb begin
		if(br_unsigned) begin				// For unsigned number
			br_equal = w0;
			br_less  = w1;
		end

		else begin					// For signed number
			br_equal = w2;
		
			case(diff_sign)
				1'b1: begin			// rs1 and rs2 have different signed bit
					if     (neg_rs1) begin	// If rs1 < 0 => rs2 > 0 => rs1 < rs2
						br_less  =   1;	
					end
					else if(!neg_rs1) begin // If rs1 > 0 => rs2 < 0 => rs1 > rs2
						br_less  =   0;
					end

					else
						br_less  =   0;	// Default
				end

				1'b0:  br_less  = w1; // Negative and Positive compare bits the same
			endcase
		end
	end
endmodule





	

	
