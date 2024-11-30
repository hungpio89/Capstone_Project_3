/* verilator lint_off UNOPTFLAT */
module mag_comparator_4bit_slave (
// Input and Output 
	// Input Logic
	input logic	a,
	input logic 	b,
	input logic	a_e_b,
	input logic	a_m_b,
	input logic	a_l_b,
	
	// Output logic 
	output logic	a_equal_b,
	output logic	a_more_b,
	output logic	a_less_b
);

// Local declaration
	
	assign 		a_equal_b = a_e_b & (a ~^ b);
	assign		a_more_b = a_m_b | (a & ~b & a_e_b);
	assign		a_less_b = a_l_b | (~a & b & a_e_b);
	
endmodule
