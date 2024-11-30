module	mux10to1_32bit	(
// Input and output logic 
	// Input logic 
	input logic 	[31 : 0]		a0,
	input logic 	[31 : 0]		a1,
	input logic 	[31 : 0]		a2,
	input logic 	[31 : 0]		a3,
	input logic 	[31 : 0]		a4,
	input logic 	[31 : 0]		a5,
	input logic 	[31 : 0]		a6,
	input logic 	[31 : 0]		a7,
	input logic 	[31 : 0]		a8,
	input logic 	[31 : 0]		a9,
	input logic 	[3 : 0]		sel,
	
	// Output logic
	output logic 	[31 : 0]		s
);

always_comb	begin
	case(sel)
		4'b0000:	s = a0;
		4'b0001:	s = a1;
		4'b0010:	s = a2;
		4'b0011:	s = a3;
		4'b0100:	s = a4;
		4'b0101:	s = a5;
		4'b0110:	s = a6;
		4'b0111:	s = a7;
		4'b1000:	s = a8;
		4'b1001:	s = a9;
		default: s = 32'b0;
	endcase
end
endmodule
