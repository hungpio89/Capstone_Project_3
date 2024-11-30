module sub_comp (
// Input and Output 
	// Input Logic
	input logic	[31 : 0]		rs1,
	input logic 	[31 : 0]		rs2,
	
	// Output logic 
	output logic 	[31 : 0]		data_out
);

	// Local declaration 
	//logic 							cout;
	logic				[31 : 0]		rs2_neg;
	
// Apply the formular: a - b = a + (~b + 1)
	// Invert component
	inverter_32bit		inv_inst (
		// Input Logic
					.data_in			(rs2),
		// Output logic 
					.data_out		(rs2_neg)
	);
	
	// Adder component 
	adder_32bit		add_inst (
		// Input Logic
					.a				(rs1),
					.b				(rs2_neg),
					.cin				(1),
	
		// Output logic 
					.s				(data_out)
					//.cout				(cout)
	);
endmodule
