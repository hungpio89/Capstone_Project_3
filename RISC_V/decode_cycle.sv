module decode_cycle (
// Input signals
	input	logic							clk_i, 
	input	logic							rst_ni,
	input logic							WB_rd_wren,					// For regfile
	input logic 						ID_stall_en,
	input logic 						ID_rst_n,	
	
	input logic		[31 : 0]			ID_inst,
	input logic 	[31 : 0]			ID_pc, ID_pc_four,
	
	// For Regfile write back 
	input logic 	[4 : 0]				WB_rd_addr,
	input logic 	[31 : 0]			WB_rd_data,
		// Data write harzard to regfile
	input logic 					sel_rs1_wb, sel_rs2_wb,
	
	
	output logic	[31 : 0]			EX_rs1_data, EX_rs2_data,
	output logic 	[31 : 0]			EX_pc, EX_pc_four,
	output logic 	[31 : 0]			EX_imm_value,
	output logic	[ 4 : 0]			EX_rs1_addr, EX_rs2_addr, EX_rd_addr,		// For forwarding control unit
	output logic 	[ 4 : 0]			ID_rs1_addr, ID_rs2_addr, 			// For forwarding control unit
	
	// For control signal
	output logic 							EX_rd_wren,
	output logic 			[15 : 0]		EX_ex_en,
	output logic 			[8 : 0]		EX_mem_en,
	output logic 			[1 : 0]				EX_wb_en,
	output logic 					EX_rd_rs2_en,					// For forwarding control unit
	output logic 					EX_ld_en,
	output logic                   			ID_rd_rs2_en
);

// Declaration of local signals
		// Regfile
	logic				[ 4 : 0]		rs1_addr, rs2_addr, rd_addr; 
	logic 				[31 : 0]		rs1_data_raw, rs2_data_raw;
	logic				[31 : 0]		rs1_data, rs2_data;
		// Immediate generator
	logic				[24 : 0]		inst_imm;
	logic 			[31 : 0]		imm_value;
		// Control Unit
	logic 			[10 : 0] 	inst_i;
	logic		[4 : 0]						immsel;
	logic 							rd_wren;
	logic 			[15 : 0]		ex_en;
	logic 			[8 : 0]		mem_en;
	logic 			[1 : 0]				wb_en;
		// Forward control unit
	logic 			ld_en;
	logic                   rd_rs2_en;
	
	assign 			rs2_addr 		= ID_inst[24 : 20];
	assign 			rs1_addr 		= ID_inst[19 : 15];
	assign 			rd_addr 			= ID_inst[11 : 7];
	assign			inst_imm			= ID_inst[31 : 7];
	assign 			inst_i 			= {ID_inst[30], ID_inst[14:12], ID_inst[6:0]};	
	assign			ID_rs1_addr		= rs1_addr;
	assign			ID_rs2_addr		= rs2_addr;
//	assign			ID_rd_addr		= rd_addr;
	assign 			ID_rd_rs2_en		= rd_rs2_en;

// Datapath 
		// Regfile
regfile				regfile_inst		(
							.clk_i			(clk_i),	// positive clock.
							.rst_ni			(rst_ni),	// low negative reset
							.rs1_addr		(rs1_addr),
							.rs2_addr		(rs2_addr),
							.rd_addr			(WB_rd_addr),
							.rd_data			(WB_rd_data),
							.rd_wren			(WB_rd_wren),
							
							.rs1_data		(rs1_data_raw),
							.rs2_data		(rs2_data_raw)
);
mux2to1_32bit			sel_rd_inst1		(
							.a			(rs1_data_raw),
							.b			(WB_rd_data),
							.sel			(sel_rs1_wb),

							.s			(rs1_data)						
);

mux2to1_32bit			sel_rd_inst2		(
							.a			(rs2_data_raw),
							.b			(WB_rd_data),
							.sel			(sel_rs2_wb),

							.s			(rs2_data)						
);
		// Immediate generation
imm_gen				imm_inst			(
							.inst				(inst_imm),
							.immsel			(immsel),
							.imm				(imm_value)
);	

		// Control unit of the processor
ctrl_unit			ctr_inst			(
						.inst				(inst_i),
	
	
	// Output 
		// IF Stage
						.pc_sel						(ex_en[0]),			// 0 Select PC + 4, 1 select PC + imm						
		// ID Stage
						.imm_sel						(immsel),			// Select the immediate for R, I, S, B, J
						.rd_wren						(rd_wren),			// Write data into the regfile
		// EX Stage 
						.br_unsigned				(ex_en[1]),			// 1 if the two operands are unsigned.
						.op_a_sel					(ex_en[3 : 2]),	// 01 is PC select, 00 is rs1_data, 11 and 10 is 0
						.op_b_sel					(ex_en[4]),			// Select operand B source: 0 if rs2, 1 if imm
						.alu_op						(ex_en[8 : 5]),	// Option for alu
						.j_en						(ex_en[9]),
						.br_en						(ex_en[15 : 10]),	// For PC select
						
		// MEM Stage 
						.mem_wren					(mem_en[0]),			// Write data into the LSU, 1: write, 0: read
						.sb_en						(mem_en[1]),
                  .sh_en                  (mem_en[2]),
						.sw_en                  (mem_en[3]),
                  .lb_en                  (mem_en[4]),
                  .lh_en                  (mem_en[5]),
                  .lbu_en                 (mem_en[6]),
                  .lhu_en                 (mem_en[7]),
						.lw_en                  (mem_en[8]),
		// WB Stage 
						.wb_sel						(wb_en),				// 00: load_data, 01: alu_data, 10: pc + 4
					// Forward control unit
						.ID_rd_rs2_en		(rd_rs2_en),
						.ld_en			(ld_en)
);

// Mux for Non-forwarding unit
//always @(*) begin
//	case (ID_ctr_sel) 
//		1'b0:begin
//			ex_en_m 		= 0;
//			mem_en_m		= 0;
//			wb_en_m 		= 0;
//			rd_wren_m	= 0;
//		end
//		1'b1:begin
//			ex_en_m 		= ex_en;
//			mem_en_m		= mem_en;
//			wb_en_m 		= wb_en;
//			rd_wren_m	= rd_wren;
//		end
//	endcase
//end 
logic           rst_n;
assign          rst_n   = ID_rst_n & rst_ni;
always @(posedge clk_i or negedge rst_n) begin
	if (!rst_n) begin
		EX_rs1_data 		<= 0;
		EX_rs2_data			<= 0;
		EX_pc					<= 0;
		EX_pc_four			<= 0;
		EX_imm_value 		<= 0;
		EX_rs1_addr			<= 0;
		EX_rs2_addr			<= 0;
		EX_rd_addr			<= 0;
		
		EX_rd_wren			<= 0;
		EX_ex_en				<= 0;
		EX_mem_en			<= 0;
		EX_wb_en				<= 0;
		EX_rd_rs2_en			<= 0;
		EX_ld_en			<= 0;
	end
	
	else if (ID_stall_en) begin
		EX_rs1_data 		<= rs1_data;
		EX_rs2_data			<= rs2_data;
		EX_pc					<= ID_pc;
		EX_pc_four			<= ID_pc_four;
		EX_imm_value 		<= imm_value;
		EX_rs1_addr			<= rs1_addr;
		EX_rs2_addr			<= rs2_addr;
		EX_rd_addr			<= rd_addr;
		
		EX_rd_wren			<= rd_wren;
		EX_ex_en				<= ex_en;
		EX_mem_en			<= mem_en;
		EX_wb_en				<= wb_en;
		EX_rd_rs2_en			<= rd_rs2_en;
		EX_ld_en			<= ld_en;
	end
	
	else begin
		EX_rs1_data 		<= EX_rs1_data;
		EX_rs2_data			<= EX_rs2_data;
		EX_pc					<= EX_pc;
		EX_pc_four			<= EX_pc_four;
		EX_imm_value 		<= EX_imm_value;
		EX_rs1_addr			<= EX_rs1_addr;
		EX_rs2_addr			<= EX_rs2_addr;
		EX_rd_addr			<= EX_rd_addr;
		
		EX_rd_wren			<= EX_rd_wren;
		EX_ex_en				<= EX_ex_en;
		EX_mem_en			<= EX_mem_en;
		EX_wb_en				<= EX_wb_en;
		EX_rd_rs2_en			<= EX_rd_rs2_en;
		EX_ld_en			<= EX_ld_en;
	end
end 
endmodule

