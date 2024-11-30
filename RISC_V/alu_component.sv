/* verilator lint_off UNOPTFLAT */
module alu_component	(
// Input and Output 
	// Input Logic
	input logic	[31 : 0]	operand_a,
	input logic 	[31 : 0]	operand_b,
	input		[3 : 0]		alu_op,
	
	// Output logic 
	output logic 	[31 : 0]	alu_data
);

// Local declaration
	//logic 				slt_1bit, sltu_1bit;
	
	logic		[31 : 0]		add;
	logic		[31 : 0]		sub;
	logic		[31 : 0]		slt;
	logic		[31 : 0]		sltu;
	logic		[31 : 0]		xor_;
	logic		[31 : 0]		and_;
	logic		[31 : 0]		or_;
	logic		[31 : 0]		sll;
	logic		[31 : 0]		srl;
	logic		[31 : 0]		sra;
	
	//wire	slt		= {31'b0, slt_1bit};
	//wire	sltu		= {31'b0, sltu_1bit};
	
// Function component
	// ADD function
add_comp				add_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out		(add)
);
	// SUB function
sub_comp				sub_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out		(sub)
);
	
	// SLT function and SLTU function
slt_sltu_comp		sl_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out_s		(slt),
					.data_out_u		(sltu)
);	
	// XOR function
xor_comp				xor_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out		(xor_)	
);	
	// OR function
or_comp				or_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out		(or_)
);		
	// AND function
and_comp				and_func		(
		// Input Logic
					.rs1			(operand_a),
					.rs2			(operand_b),
	
		// Output logic 
					.data_out		(and_)
);		
	// SLL, SRL and SRA function 
shift_comp			shift_comp		(
					.rs1			(operand_a),
					.rs2			(operand_b),
	
	// Output logic 
					.data_out_sll		(sll),
					.data_out_srl		(srl),
					.data_out_sra		(sra)
);
	
	// Select result for ALU
mux10to1_32bit		select_inst		(
	// Input logic 
					.a0				(add),
					.a1				(sub),
					.a2				(slt),
					.a3				(sltu),
					.a4				(xor_),
					.a5				(or_),
					.a6				(and_),
					.a7				(sll),
					.a8				(srl),
					.a9				(sra),
					.sel				(alu_op),
	
	// Output logic
					.s				(alu_data)	
);

endmodule
