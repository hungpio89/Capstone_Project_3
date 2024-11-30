module forward_ctr_unit (
// Input signal for Data Harzard without load instruction
	input logic 				MEM_rd_wren, 
	input logic 				WB_rd_wren,
	
// Input signal for Data Harzard with load instruction
	// 1: write, 0: Read
	input logic 				MEM_mem_wren,							// For load instruction that have to load for the first next instruction data
	input logic 				MEM_ld_en,
	input logic 				WB_mem_wren, 							// For load instruction that have to load for the second next instruction data
	input logic 				WB_ld_en,
	
	input logic 	[4 : 0]	ID_rs1_addr, ID_rs2_addr,				
	//input logic 	[4 : 0]	WB_rd_addr_check,
	
	input logic 	[4 : 0]	EX_rs1_addr, EX_rs2_addr,
	input logic 	[4 : 0]	MEM_rd_addr, WB_rd_addr,

	input logic 		EX_rd_rs2_en,
	input logic             ID_rd_rs2_en,
	
// Ourput signal for select data
	output logic 	[1 : 0]	forwardA_en, forwardB_en,
// Output signal for hold and reset stage
	// Hold IF ID EX  and MEM stage 
	output logic 				IF_ID_en, ID_EX_en, EX_MEM_en, pc_en,
	output logic				sel_rs1_wb, sel_rs2_wb,
	// Reset data from MEM stage 
	output logic 				EX_MEM_rst_n
);

// Set No FW:00
// Set FW bit from WB:01
// Set FW bit from MEM:10

////////////////////////////////////////////////////////////
// Forward from A with load and without load
always @(*) begin
	// Forward for operand A:
		// (MEM_rd_wren | !MEM_mem_wren) Forward the data for load and without load instruction (except store)
		// (!MEM_rd_wren | MEM_mem_wren)	Forward the data for store, just consider the rs1 and rd => ForwardA
	if ((MEM_rd_wren | (!MEM_mem_wren & MEM_ld_en)) && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs1_addr) )	// Forward from MEM 
		forwardA_en = 2'b10;
		
	else if ((WB_rd_wren | (!WB_mem_wren & WB_ld_en)) && (WB_rd_addr != 0) && (WB_rd_addr == EX_rs1_addr))	// Forward from WB
		forwardA_en = 2'b01;
		
	else 
		forwardA_en = 2'b00;
		
	// Forward for operand B:
		// (MEM_rd_wren | MEM_mem_wren) Forward the data for load and without load instruction	
	if ((MEM_rd_wren | (!MEM_mem_wren & MEM_ld_en)) && (MEM_rd_addr != 0) && ((MEM_rd_addr == EX_rs2_addr) & !EX_rd_rs2_en ))	// Forward from MEM 
		forwardB_en = 2'b10;
		
	else if ((WB_rd_wren | (!WB_mem_wren & WB_ld_en)) && (WB_rd_addr != 0) && ((WB_rd_addr == EX_rs2_addr) & !EX_rd_rs2_en))	// Forward from WB
		forwardB_en = 2'b01;
		
	else 
		forwardB_en = 2'b00; 
end

	
	// Stall and Nop the state while dealing with harzard
	// In case of some instruction of I type, L type, jalr which is not
	// used the address of rs2, the imm value that can be overlap the
	// address rd (in the position rs2 address)
always @(*) begin 
	if ((!MEM_mem_wren & MEM_ld_en) && (MEM_rd_addr != 0) && (MEM_rd_addr == EX_rs1_addr)) begin
		IF_ID_en		= 0;
		ID_EX_en		= 0;
		EX_MEM_en		= 0;
		pc_en			= 0;
		
		EX_MEM_rst_n		= 0;
	end

	else if ((!MEM_mem_wren & MEM_ld_en) && (MEM_rd_addr != 0) && ((MEM_rd_addr == EX_rs2_addr) & !EX_rd_rs2_en)) begin
                IF_ID_en                = 0;
                ID_EX_en                = 0;
                EX_MEM_en               = 0;
                pc_en                   = 0;

                EX_MEM_rst_n            = 0;
        end
	
	else begin
		IF_ID_en		= 1;
		ID_EX_en		= 1;
		EX_MEM_en		= 1;
		pc_en			= 1;
		
		EX_MEM_rst_n		= 1;
	end
	

	// Harzard for regfile 
	if (WB_rd_wren && (WB_rd_addr != 0) && (WB_rd_addr == ID_rs1_addr)) 
		sel_rs1_wb = 1;
	else
		sel_rs1_wb = 0;

	if (WB_rd_wren && (WB_rd_addr != 0) && ((WB_rd_addr == ID_rs2_addr) & !ID_rd_rs2_en)) 
		sel_rs2_wb = 1;
	else
		sel_rs2_wb = 0;
end
endmodule	
