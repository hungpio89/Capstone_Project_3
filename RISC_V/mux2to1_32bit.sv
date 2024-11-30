module mux2to1_32bit	(
// Input and output logic 
	// Input logic 
	input logic 	[31 : 0]		a,
	input logic 	[31 : 0]		b,
	input logic 					sel,
	
	// Output logic
	output logic 	[31 : 0]		s
);

always_comb	begin
	case(sel)
		1'b0:	s = a;
		1'b1:	s = b;
	endcase
end

endmodule
