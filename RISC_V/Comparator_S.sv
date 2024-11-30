/* verilator lint_off UNOPTFLAT */
module Comparator_S	(
// Input and Output 
	// Input Logic
	input logic		[30 : 0]	a,
	input logic 		[30 : 0]	b,
	
	// Output logic 
	output logic				a_equal_b,
	output logic				a_less_b
);

	// Local declaration
	logic			[30 : 0]	a_e_b;
	logic			[30 : 0]	a_m_b;
	logic			[30 : 0]	a_l_b;
	
	assign			a_equal_b = a_e_b[0];
	assign			a_less_b  = a_l_b[0];

	wire _unused_ok = &{1'b0, a_m_b, 1'b0};	
	
	// Master comparator - Compare 4 MSB of a and b
mag_comparator_4bit_master				master_inst	(
									.a					(a[30]),
									.b					(b[30]),
		
	// Output logic 
									.a_equal_b				(a_e_b[30]),
									.a_more_b				(a_m_b[30]),
									.a_less_b				(a_l_b[30])
	);
	
	// 7 slave comparator-4bit 
genvar i;
generate 
	for (i = 0; i < 30; i = i + 1) begin: gen_compare32
		mag_comparator_4bit_slave		slave_inst	(
									.a					(a[29 - i]),
									.b					(b[29 - i]),
									.a_e_b					(a_e_b[30 - i]),
									.a_m_b					(a_m_b[30 - i]),
									.a_l_b					(a_l_b[30 - i]),
	
	// Output logic 
									.a_equal_b				(a_e_b[29 - i]),
									.a_more_b				(a_m_b[29 - i]),
									.a_less_b				(a_l_b[29 - i])
		);
	end
endgenerate

endmodule
