module mag_comparator_4bit_master (
// Input and Output 
	// Input Logic
	input logic					a,
	input logic 				b,
	
	// Output logic 
	output logic				a_equal_b,
	output logic				a_more_b,
	output logic				a_less_b
 );

// Local declaration 
	assign 		a_equal_b = a ~^ b;
	assign		a_more_b = a & ~b;
	assign		a_less_b = ~a & b;
	
endmodule
