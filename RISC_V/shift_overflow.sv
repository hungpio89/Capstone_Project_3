module shift_overflow	(
// Input and Output 
	// Input Logic
	input logic		[31 : 0]		sll,
	input logic 		[31 : 0]		sra,
	input logic 		[31 : 0]		srl,
	
	input	logic 		[31 : 0]		rs2,
	input 						rs1_sign,
		
	// Output logic 
	output logic		[31 : 0]		sll_out,
	output logic 		[31 : 0]		sra_out,
	output logic 		[31 : 0]		srl_out
);

//	Local declaration 
	logic 						a_e_b, a_m_b, a_l_b, overflow_signal;
	logic			[31 : 0]		overflow_value;
	
	assign		overflow_signal	= a_m_b | a_e_b;

	 wire _unused_ok = &{1'b0, a_l_b, 1'b0};
//	assign				overflow_0			= 32'b0;
//	assign				overflow_1			= {31'b1111111111111111111111111111111, rs1_sign};
// Check rs2 over 32 or not
comparator_32bit			check_inst	(
	// Output logic 
					.a		(rs2),
					.b		(32'b0000_0000_0000_0000_0000_0000_0010_0000),
	
	// Output logic 
					.a_equal_b	(a_e_b),
					.a_more_b	(a_m_b),
					.a_less_b	(a_l_b)
);
// Select the result for sll and srl
mux2to1_32bit				sll_select	(
	// Input
					.a		(sll),
					.b		(32'b0),
					.sel		(overflow_signal),
	// Output
					.s		(sll_out)
);

mux2to1_32bit				srl_select	(
	// Input
					.a		(srl),
					.b		(32'b0),
					.sel		(overflow_signal),
	// Output
					.s		(srl_out)
);

// Select the result for sra
	// select the overflow vaule 32'b0 or 32'b1111_1111_1111_1111_1111_1111_1111_1111
check_mux					over_select	(
	// Input
					.sel		(rs1_sign),
	// Output
					.s		(overflow_value)
);

	// result for sra
mux2to1_32bit				sra_select	(
	// Input
					.a		(sra),
					.b		(overflow_value),
					.sel		(overflow_signal),
	// Output
					.s		(sra_out)
);

endmodule
