module mux4to1_4bit
(
	input  logic [ 1 :  0] sel,		// arrange bit 0 ~ done, bit 1 ~ start
	input  logic [ 3 :  0] in,
		
	output logic [ 3 :  0] out
);

	always_comb begin
		case (sel)
			2'b00: out <= 4'b0;
			2'b01: out <= 4'b0;
			2'b10: out <= in + 4'b1;
			2'b11: out <= 4'b0;
		endcase
	end

endmodule
