module check_mux	(
// Input and output logic 
	// Input logic 
	input logic 					sel,
	
	// Output logic
	output logic 	[31 : 0]		s
);

mux2to1_32bit				over_select	(
	// Input
						.a						(32'b0000_0000_0000_0000_0000_0000_0000_0000),
						.b						(32'b1111_1111_1111_1111_1111_1111_1111_1111),
						.sel					(sel),
	// Output
						.s						(s)
);

endmodule
