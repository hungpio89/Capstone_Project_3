/* verilator lint_off UNOPTFLAT */
module add_comp (
// Input and Output 
	// Input Logic
	input logic	[31 : 0]	rs1,
	input logic 	[31 : 0]	rs2,
	
	// Output logic 
	output logic 	[31 : 0]	data_out
);

	// Local declaration 
	//logic 			cout;
	
	// Adder component 
	adder_32bit			add_inst (
		// Input Logic
					.a			(rs1),
					.b			(rs2),
					.cin			(0),
	
		// Output logic 
					.s			(data_out)
					//.cout				(cout)
	);
endmodule
