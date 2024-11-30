module decode_hex (
  input 	logic [3:0] hex_digit,
  output logic [6:0] segment
);
	always_comb begin
		case (hex_digit)
			4'h0: segment = 7'b1000000; // Displays 0
			4'h1: segment = 7'b1111001; // Displays 1
			4'h2: segment = 7'b0100100; // Displays 2
			4'h3: segment = 7'b0110000; // Displays 3
			4'h4: segment = 7'b0011001; // Displays 4
			4'h5: segment = 7'b0010010; // Displays 5
			4'h6: segment = 7'b0000010; // Displays 6
			4'h7: segment = 7'b1111000; // Displays 7
			4'h8: segment = 7'b0000000; // Displays 8
			4'h9: segment = 7'b0011000; // Displays 9
		
			default: segment = 7'b1111111; // Displays blank
		endcase
	end
endmodule
