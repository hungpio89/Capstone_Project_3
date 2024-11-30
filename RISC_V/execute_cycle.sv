module execute_cycle (
// Inptu and output signal 
	input	logic								clk_i, 
	input	logic								rst_ni,
	input logic 							EX_stall_en,
	input logic 							EX_rst_n,

	input logic			[31 : 0]			EX_rs1_data, EX_rs2_data,
	input logic 		[31 : 0]			EX_pc, EX_pc_four,
	input logic 		[31 : 0]			EX_imm_value,
	input logic			[ 4 : 0]			EX_rd_addr,				// For forwarding control unit
	
		// For forward Control Unit
	
	input logic 		[1 : 0]			forwardA_en, forwardB_en,
	input logic 		[31 : 0]			MEM_forwardA_data, MEM_forwardB_data,
	input logic 		[31 : 0]			WB_forwardA_data, WB_forwardB_data,
	input logic 					EX_ld_en,
	
	// For control signal
	input logic 							EX_rd_wren,
	input logic 			[15 : 0]		EX_ex_en,
	input logic 			[8 : 0]		EX_mem_en,
	input logic 			[1 : 0]		EX_wb_en,

	output logic 			[31 : 0]		MEM_alu_data,
	// For forwarding control unit
	output logic			[ 4 : 0]		MEM_rd_addr,	
	output logic 			[31 : 0]		MEM_rs2_data,											// For Store instruction
	output logic 			[31 : 0]		MEM_pc_four,

	// For recognize the instruction of I type, L type, jalr which is not
        // used the address of rs2, the imm value that can be overlap the
        // address rd (in the position rs2 address)

	// For control signal
	output logic 					MEM_rd_wren,
	output logic 			[8 : 0]		MEM_mem_en,
	output logic 			[1 : 0]		MEM_wb_en,
	
	// For Chosing PC address
	output logic 							MEM_pc_br,
	// Forward control unit
	output logic 					MEM_ld_en
);


// Declaration of local logic 	
	// For Branch and Jump instruction 
	logic 									br_lt, br_eq;
	logic 									br_unpc, br_pc;
	logic 									branch_en;
	logic 									pc_br;
	
	// br_en			= {bgeu_en, bltu_en, bge_en, blt_en, bne_en, beq_en}; with br_en = EX_ex_en[15 : 10]
	// br_unsigned	= EX_ex_en[1]
	// j_en 			= EX_ex_en[9]
	assign		br_unpc 	= (EX_ex_en[15] & ~br_lt) | (EX_ex_en[14] & br_lt);
	assign		br_pc 		= (EX_ex_en[13] & (br_eq | ~br_lt)) | (EX_ex_en[12] & br_lt) | (EX_ex_en[11] & ~br_eq) | (EX_ex_en[10] & br_eq);
	assign 		branch_en	= (br_unpc & EX_ex_en[1]) | (br_pc & ~EX_ex_en[1]);
	
	assign		pc_br			= EX_ex_en[9] | branch_en | EX_ex_en[0];				// pc_br = j_en | branch_en | pc_sel;
	// For ALU and select operand 
	logic 		[31 : 0]		operand_a, operand_b, alu_data;
	logic 		[31 : 0]		forward_operand_b, forward_operand_a;
	
// Datapath 
		// Branch comparator
branch_comparator		brc_inst			(
							.rs1_data		(forward_operand_a),
							.rs2_data		(forward_operand_b),
							.br_unsigned	(EX_ex_en[1]),
							
							.br_less			(br_lt),			// For branch 
							.br_equal		(br_eq)			// For branch 
);

		// ALU and select operands for control signal 
mux3to1_32bit			select_a_inst	(
							.a0				(forward_operand_a),
							.a1				(EX_pc),
							.a2				(32'b0),
							.sel				(EX_ex_en[3 : 2]),		// 01 is PC select, 00 is rs1_data, 11 and 10 is 0
							
							.s					(operand_a)
);
mux2to1_32bit			select_b_inst	(
							.a					(forward_operand_b),
							.b					(EX_imm_value),
							.sel				(EX_ex_en[4]),		// 1 is imm select, 0 is rs2_data
							
							.s					(operand_b)
);

		// select operands for forward signal 
		// 00: No forwarding; 01: Forward to mem; 10 and 11: forward to wb
mux3to1_32bit			sel_forwardA_inst	(
//							.a0				(operand_a),
							.a0				(EX_rs1_data),
							.a1				(WB_forwardA_data),
							.a2				(MEM_forwardA_data),
							.sel				(forwardA_en),		// 00: No forwarding; 01: Forward to wb; 10 and 11: forward to mem
							
							.s					(forward_operand_a)
);
mux3to1_32bit			sel_forwardB_inst	(
//							.a0				(operand_b),
							.a0				(EX_rs2_data),
							.a1				(WB_forwardB_data),
							.a2				(MEM_forwardB_data),
							.sel				(forwardB_en),		// 00: No forwarding; 01: Forward to wb; 10 and 11: forward to mem
							
							.s					(forward_operand_b)
);


alu_component			alu_inst			(
							.operand_a		(operand_a),
							.operand_b		(operand_b),
							.alu_op			(EX_ex_en[8 : 5]),
					
							.alu_data		(alu_data)
);
/////////////////////////////////////////
logic 		rst_n;
assign 		rst_n	= EX_rst_n & rst_ni;
always @(posedge clk_i or negedge rst_n) begin
	if (!rst_n) begin
		MEM_alu_data 		<= 0;
		MEM_rs2_data		<= 0;
		MEM_pc_four			<= 0;
		MEM_rd_addr			<= 0;
		
		MEM_rd_wren			<= 0;
		MEM_mem_en			<= 0;
		MEM_wb_en			<= 0;
		MEM_pc_br			<= 0;
		MEM_ld_en			<= 0;
	end
	
	else if (EX_stall_en) begin
		MEM_alu_data 		<= alu_data;
		MEM_rs2_data		<= forward_operand_b;
		MEM_pc_four			<= EX_pc_four;
		MEM_rd_addr			<= EX_rd_addr;
		
		MEM_rd_wren			<= EX_rd_wren;
		MEM_mem_en			<= EX_mem_en;
		MEM_wb_en			<= EX_wb_en;
		MEM_pc_br			<= pc_br;
		MEM_ld_en			<= EX_ld_en;
	end
	
	else begin
		MEM_alu_data 		<= MEM_alu_data;
		MEM_rs2_data		<= MEM_rs2_data;
		MEM_pc_four			<= MEM_pc_four;
		MEM_rd_addr			<= MEM_rd_addr;
		
		MEM_rd_wren			<= MEM_rd_wren;
		MEM_mem_en			<= MEM_mem_en;
		MEM_wb_en			<= MEM_wb_en;
		MEM_pc_br			<= MEM_pc_br;
		MEM_ld_en			<= MEM_ld_en;
	end
end 

endmodule
