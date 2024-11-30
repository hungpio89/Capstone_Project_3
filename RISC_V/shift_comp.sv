module shift_comp	(
// Input and Output 
	// Input Logic
	input logic		[31 : 0]		rs1,
	input logic 	[31 : 0]		rs2,
	
	// Output logic 
	output logic 	[31 : 0]		data_out_sll,
	output logic 	[31 : 0]		data_out_srl,
	output logic 	[31 : 0]		data_out_sra
);
// Local declaration
	logic				[31 : 0]		sll_out, sra_out, srl_out;
// Component for sll 
shift_left_32bit				sll_inst		(
	// Input Logic
									.in			(rs1),
									.shift_sel	(rs2),
	
	// Output logic 
									.out			(sll_out)
);
// Component for srl
srl_32bit						srl_inst		(
	// Input Logic
									.in			(rs1),
									.shift_sel	(rs2),
	
	// Output logic 
									.out			(srl_out)
);
// Component for sra
sra_32bit						sra_inst		(
	// Input Logic
									.in			(rs1),
									.shift_sel	(rs2),
	
	// Output logic 
									.out			(sra_out)
);

// Output the result for 3 commands
shift_overflow					result_inst	(
	// Input Logic
									.sll			(sll_out),
									.sra			(sra_out),
									.srl			(srl_out),
	
									.rs2			(rs2),
									.rs1_sign	(rs1[31]),
		
	// Output logic 
									.sll_out		(data_out_sll),
									.sra_out		(data_out_sra),
									.srl_out		(data_out_srl)
);

endmodule

