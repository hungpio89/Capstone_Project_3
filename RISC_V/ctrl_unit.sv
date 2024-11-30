module ctrl_unit (
// Input and output
	// Input
	input logic	[10 : 0]		inst,			// inst[30] = inst_i[10], inst[14:12] = inst_i[ 9: 7] , inst[ 6: 0] = inst_i[ 6: 0]
//	input logic					br_eq, br_lt,
	
	// Output 
	output logic				pc_sel,			// 0 Select PC + 4, 1 select PC + imm
	output logic	[4 : 0]	imm_sel,				// Select the immediate for R, I, S, B, J
	output logic				br_unsigned,		// 1 if the two operands are unsigned.
	output logic	[1 : 0]	op_a_sel,		// Select operand A source: 00 if rs1, 01 if PC 10 or 11 is 0
	output logic				op_b_sel,		// Select operand B source: 0 if rs2, 1 if imm
	output logic	[3 : 0]	alu_op,			// Option for alu
	output logic				mem_wren,		// Write data into the LSU, 1: write, 0: read
	output logic				rd_wren,		// Write data into the regfile 
	output logic	[1 : 0]	wb_sel,			// 00: load_data, 01: alu_data, 10: pc+4
// Output for load opertation with diferent option
	output logic            sb_en,
   output logic            sh_en,
	output logic            sw_en,
	output logic				lb_en, 
	output logic				lh_en, 
	output logic 				lbu_en, 
	output logic 				lhu_en,
	output logic            lw_en,
// For B - type and J - Type
	output logic 				j_en,
	output logic 	[5 : 0]	br_en,
// For Forward control unit
	output logic 		ID_rd_rs2_en,
	output logic 		ld_en	
	
);

// Local declaration
	logic		[4 : 0]			opcode_dif;
	logic		[2 : 0]			funct3;
	logic					funct7_dif;
	
	assign	opcode_dif	= 	inst[6 : 2];				
	assign	funct3		= 	inst[9 : 7];
	assign	funct7_dif	= 	inst[10];
		
	// Instruction available
	logic					rv32i;	
	
	assign	rv32i		=	inst[0] & inst[1];
		
	// L, R, I, U, S, B, J type
	logic					r_type, i_type, l_type, s_type, b_type;	
	
	assign	r_type	= opcode_dif[3] & opcode_dif[2] & (~opcode_dif[0]) & rv32i;					//Opcode = 0110011
	assign	i_type	= (~opcode_dif[3]) & opcode_dif[2] & (~opcode_dif[0]) & rv32i;					//Opcode = 0010011
	assign	l_type	= ~(opcode_dif[4] | opcode_dif[3] | opcode_dif[2] | opcode_dif[1] | opcode_dif[0]) & rv32i;	//Opcode = 0000011
	assign	s_type	= opcode_dif[3] & (~opcode_dif[2]) & rv32i;							//Opcode = 0100011
	assign	b_type	= opcode_dif[4] & (~opcode_dif[2]) &(~opcode_dif[1]) & (~opcode_dif[0]) & rv32i;		//Opcode = 1100011

//	assign	j_type		= 	opcode_dif[4] & (~opcode_dif[1]) & (~opcode_dif[0]);						// 	Opcode = 1101111
//	assign	jr_type		= 	opcode_dif[4] & (~opcode_dif[1]) & (~opcode_dif[0]);						// 	Opcode = 1100111
//	assign	u_type		= 	opcode_dif[4] & opcode_dif[3] & opcode_dif[2] & opcode_dif[1] & opcode_dif[0];			// 	Opcode = 0110111
		
	// R-Type
	logic			add_en, sub_en, sll_en, slt_en, sltu_en, xor_en, srl_en, sra_en, or_en, and_en;
		assign	add_en		= 	r_type & ~(funct3[2] | funct3[1] | funct3[0]) & ~funct7_dif;
		assign	sub_en		= 	r_type & ~(funct3[2] | funct3[1] | funct3[0]) & funct7_dif;
		
		assign	srl_en		= 	r_type & (funct3[2] & ~funct3[1] & funct3[0]) & ~funct7_dif;
		assign	sra_en		= 	r_type & (funct3[2] & ~funct3[1] & funct3[0]) & funct7_dif;
		
		assign	sll_en		= 	r_type & (~funct3[2] & ~funct3[1] & funct3[0]);
		assign	slt_en		= 	r_type & (~funct3[2] & funct3[1] & ~funct3[0]);
		assign	sltu_en		= 	r_type & (~funct3[2] & funct3[1] & funct3[0]);
		assign	xor_en		= 	r_type & (funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	or_en			= 	r_type & (funct3[2] & funct3[1] & ~funct3[0]);
		assign	and_en		= 	r_type & (funct3[2] & funct3[1] & funct3[0]);
	// I-Type
	logic			addi_en, slli_en, slti_en, sltiu_en, xori_en, srli_en, srai_en, ori_en, andi_en;
		assign	addi_en		= 	i_type & ~(funct3[2] | funct3[1] | funct3[0]);
		
		assign	srli_en		= 	i_type & (funct3[2] & ~funct3[1] & funct3[0]) & ~funct7_dif;
		assign	srai_en		= 	i_type & (funct3[2] & ~funct3[1] & funct3[0]) & funct7_dif;
		
		assign	slli_en		= 	i_type & (~funct3[2] & ~funct3[1] & funct3[0]);
		assign	slti_en		= 	i_type & (~funct3[2] & funct3[1] & ~funct3[0]);
		assign	sltiu_en		= 	i_type & (~funct3[2] & funct3[1] & funct3[0]);
		assign	xori_en		= 	i_type & (funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	ori_en		= 	i_type & (funct3[2] & funct3[1] & ~funct3[0]);
		assign	andi_en		= 	i_type & (funct3[2] & funct3[1] & funct3[0]);
	// L-Type
	//logic			lb_en, lh_en, lw_en, lbu_en, lhu_en;
	//logic			lw_en;
		assign	lb_en		= 	l_type & (~funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	lh_en		= 	l_type & (~funct3[2] & ~funct3[1] & funct3[0]);
		assign	lw_en		= 	l_type & (~funct3[2] & funct3[1] & ~funct3[0]);
		assign	lbu_en		= 	l_type & (funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	lhu_en		= 	l_type & (funct3[2] & ~funct3[1] & funct3[0]);
		
	// S-Type
	//logic			sb_en, sh_en; 
	//logic			sw_en;
		assign	sb_en		= 	s_type & (~funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	sh_en		= 	s_type & (~funct3[2] & ~funct3[1] & funct3[0]);
		assign	sw_en		= 	s_type & (~funct3[2] & funct3[1] & ~funct3[0]);
		
	// B-Type
	logic			beq_en, bne_en, blt_en, bge_en, bltu_en, bgeu_en;
		assign	beq_en		= 	b_type & (~funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	bne_en		= 	b_type & (~funct3[2] & ~funct3[1] & funct3[0]);
		assign	blt_en		= 	b_type & (funct3[2] & ~funct3[1] & ~funct3[0]);
		assign	bge_en		= 	b_type & (funct3[2] & ~funct3[1] & funct3[0]);
		assign	bltu_en		= 	b_type & (funct3[2] & funct3[1] & ~funct3[0]);
		assign	bgeu_en		= 	b_type & (funct3[2] & funct3[1] & funct3[0]);
		
		assign   br_en			= {bgeu_en, bltu_en, bge_en, blt_en, bne_en, beq_en};
		
	// J-Type
	logic			jal_en, jalr_en;
		assign	jalr_en		= 	opcode_dif[4] & (~opcode_dif[1]) & opcode_dif[0] & rv32i;	// Opcode = 1100111
		assign	jal_en		= 	opcode_dif[1] & rv32i;						// Opcode = 1101111
		
		assign 	j_en			= 	jalr_en | jal_en;
		
	// U-Type
	logic			lui_en, auipc_en;
		assign	auipc_en	= 	~opcode_dif[3] & opcode_dif[2] & opcode_dif[0] & rv32i;	// Opcode = 00101
		assign	lui_en		= 	opcode_dif[3] & opcode_dif[2] & opcode_dif[0] & rv32i;	// Opcode = 01101
	
	// For forward control unit
	assign		ID_rd_rs2_en	= 	l_type | i_type | jalr_en;
	assign		ld_en		= 	l_type;
always_comb begin
		pc_sel          = 0;
              	imm_sel         = 0;
              	br_unsigned     = 0;
              	op_a_sel        = 2'b00;
		op_b_sel        = 0;
              	alu_op          = 4'b0000;
              	mem_wren        = 0;
              	rd_wren         = 0;
              	wb_sel          = 2'b00;

if  (r_type)		begin				// add_en, sub_en, sll_en, slt_en, sltu_en, xor_en, srl_en, sra_en, or_en, and_en;
			pc_sel		= 0;			// PC + 4
			imm_sel		= 5'b00000;		// No select, default 0 (no use imm)
			br_unsigned	= 0;			// No select, default 0 (signed)
			op_a_sel	= 2'b00;		// Select rs1
			op_b_sel	= 0;			// Select rs2
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 1;			// write data into regfile
			wb_sel		= 2'b01;		// alu_data
		if 			(add_en)		alu_op		= 4'b0000;
			else if 	(sub_en)		alu_op		= 4'b0001;
			else if 	(srl_en)		alu_op		= 4'b1000;
			else if 	(sll_en)		alu_op		= 4'b0111;
			else if 	(slt_en)		alu_op		= 4'b0010;
			else if 	(sltu_en)		alu_op		= 4'b0011;
			else if 	(xor_en)		alu_op		= 4'b0100;
			else if 	(sra_en)		alu_op		= 4'b1001;
			else if 	(or_en)			alu_op		= 4'b0101;
			else if 	(and_en)		alu_op		= 4'b0110;
	end

		
if (i_type)	begin				//addi_en, slli_en, slti_en, sltiu_en, xori_en, srli_en, srai_en, ori_en, andi_en;
			pc_sel		= 0;			// PC + 4
			imm_sel		= 5'b00001;		// Using I format immediate generation
			br_unsigned	= 0;			// No select, default 0 (signed)
			op_a_sel	= 2'b00;		// Select rs1
			op_b_sel	= 1;			// Select imm
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 1;			// write data into regfile
			wb_sel		= 2'b01;		// alu_data
		if 			(addi_en)	alu_op		= 4'b0000;
			else if 	(slli_en)	alu_op		= 4'b0111;
			else if 	(slti_en)	alu_op		= 4'b0010;
			else if 	(sltiu_en)	alu_op		= 4'b0011;
			else if 	(xori_en)	alu_op		= 4'b0100;
			else if 	(srli_en)	alu_op		= 4'b1000;
			else if 	(srai_en)	alu_op		= 4'b1001;
			else if 	(ori_en)	alu_op		= 4'b0101;
			else if 	(andi_en)	alu_op		= 4'b0110;
	end

		
if (l_type & (lb_en | lh_en | lw_en | lbu_en | lhu_en))	begin	// lb_en, lh_en, lw_en, lbu_en, lhu_en;
			pc_sel		= 0;			// PC + 4
			imm_sel		= 5'b00001;		// Using I format immediate generation
			br_unsigned	= 0;			// No select, default 0 (signed)
			op_a_sel	= 2'b00;		// Select rs1
			op_b_sel	= 1;			// Select imm
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 1;			// write data into regfile
			wb_sel		= 2'b00;		// load_data
			alu_op		= 4'b0000;		// Add the imm to the memory address stored in rs1
		end
		
if (s_type & (sb_en | sh_en | sw_en))	begin								//sb_en, sh_en, sw_en;
			pc_sel		= 0;			// PC + 4
			imm_sel		= 5'b00010;		// Using S format immediate generation
			br_unsigned	= 0;			// No select, default 0 (signed)
			op_a_sel	= 2'b00;		// Select rs1
			op_b_sel	= 1;			// Select imm
			mem_wren	= 1;			// Write data from dmem
			rd_wren		= 0;			// No write data into regfile
			wb_sel		= 2'b00;		// No select, default 0
			alu_op		= 4'b0000;	// Add the imm to the memory address stored in rs1
		end

if (b_type)	begin						//beq_en, bne_en, blt_en, bge_en, bltu_en, bgeu_en;
			pc_sel		= 0;			// Selected in the EX stage
			imm_sel		= 5'b00100;		// Using B format immediate generation
			op_a_sel	= 2'b01;		// Select pc
			op_b_sel	= 1;			// Select imm
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 0;			// No write data into regfile
			wb_sel		= 2'b00;		// No select, default 0
			alu_op		= 4'b0000;		// Add the imm to the memory address stored in rs1
//		if 	  (beq_en & br_eq)	pc_sel = 1;	// ALU 
//		else if (beq_en & ~br_eq)	pc_sel = 0;	// PC + 4 
//		else if (bne_en & br_eq)	pc_sel = 0;	// PC + 4 
//		else if (bne_en & ~br_eq)	pc_sel = 1;	// ALU
//		else if (blt_en & br_lt)	begin
//			pc_sel 		= 1;				// ALU
//			br_unsigned	= 0;			
//			end
//		else if (blt_en & ~br_lt)	begin
//			pc_sel 		= 0;				// PC + 4
//			br_unsigned	= 0;
//			end
//		else if (bltu_en & br_lt)	begin
//			pc_sel 		= 1;				// ALU
//			br_unsigned	= 1;
//			end
//		else if (bltu_en & ~br_lt)	begin
//			pc_sel 		= 0;				// PC + 4
//			br_unsigned	= 1;
//			end
//		
//		else if (bge_en & (br_eq | ~br_lt))	begin
//			pc_sel 		= 1;				// ALU
//			br_unsigned	= 0;
//			end
//		else if (bge_en & br_lt)	begin
//			pc_sel 		= 0;				// PC + 4
//			br_unsigned	= 0;
//			end
//		else if (bgeu_en & (br_eq | ~br_lt))	begin
//			pc_sel 		= 1;				// ALU
//			br_unsigned	= 1;
//			end
//		else if (bgeu_en & br_lt)	begin
//			pc_sel 		= 0;				// PC + 4
//			br_unsigned	= 1;
//			end
		if (blt_en | bge_en | beq_en | bne_en) begin
			br_unsigned	= 0;
		end
		
		else if (bgeu_en | bltu_en) begin
			br_unsigned	= 1;
		end
		
		else begin
			br_unsigned	= 0;
		end
	end
		
if (jalr_en | jal_en) begin
			pc_sel		 = 1;			// ALU
			br_unsigned	 = 0;			// No select, default 0 (signed)
			op_b_sel	 = 1;			// Select imm
			mem_wren	 = 0;			// Read data from dmem
			rd_wren		 = 1;			// write data into regfile
			wb_sel		 = 2'b10;		// PC + 4
			alu_op		 = 4'b0000;	// Add the imm to the memory address stored in rs1
			if (jalr_en) 	begin
				op_a_sel = 2'b00;	// select rs1
				imm_sel  = 5'b00001;	// I format taking immediate
				end
			else 	begin			// jal instruction 
				op_a_sel = 2'b01;	// select PC
				imm_sel  = 5'b01000;	// J format taking immediate
				end
		end


if (lui_en) begin				// lui instruction load the immediate value imm shifted left by 12 bits into the upper 20 bits of register rd
			pc_sel		= 0;			// PC + 4
			br_unsigned	= 0;			// No select, default 0 (signed)
			imm_sel  	= 5'b10000;		// U format taking immediate
			op_a_sel	= 2'b10;		// Select 0 for 0 + imm << 12 and store into rd  
			op_b_sel	= 1;			// Select imm
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 1;			// write data into regfile
			wb_sel		= 2'b01;		// ALU
			alu_op		= 4'b0000;		// No select
	end

if (auipc_en) begin			// auipc instruction compute a 32-bit absolute address by adding the immediate value imm shifted left by 12 bits to the PC and store it in register rd
			pc_sel		= 0;			// PC + 4
			br_unsigned	= 0;			// No select, default 0 (signed)
			imm_sel  	= 5'b10000;		// U format taking immediate
			op_a_sel	= 2'b01;		// Select PC
			op_b_sel	= 1;			// Select imm
			mem_wren	= 0;			// Read data from dmem
			rd_wren		= 1;			// write data into regfile
			wb_sel		= 2'b01;		// ALU
			alu_op		= 4'b0000;		// add
end



//	else	begin
//		pc_sel		= 0;
//		imm_sel		= 0;
//		br_unsigned	= 0;
//		op_a_sel		= 0;
//		alu_op		= 4'b0000;
//		mem_wren		= 0;
//		rd_wren		= 0;
//		wb_sel		= 2'b00;
//		end
end	
endmodule
