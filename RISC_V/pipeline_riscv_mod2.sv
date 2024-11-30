module pipeline_riscv_mod2 (
// Input and output	
	input logic		[31 : 0]		io_sw_i,
	input								clk_i, 
	input								rst_ni,
	
	output			[31 : 0]		pc_debug_o,
	output logic	[31 : 0] 	io_lcd_o,
	output logic	[31 : 0] 	io_ledg_o,
	output logic	[31 : 0] 	io_ledr_o,
	output logic	[31 : 0] 	io_hex0_o,
	output logic	[31 : 0] 	io_hex1_o,
	output logic	[31 : 0] 	io_hex2_o,
	output logic	[31 : 0]		io_hex3_o,
	output logic	[31 : 0] 	io_hex4_o,
	output logic	[31 : 0] 	io_hex5_o,
	output logic	[31 : 0]		io_hex6_o,
	output logic	[31 : 0] 	io_hex7_o	
);
//////////////////////////////////////////////
// 			Local logic declaration 		  //
//////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// IF Stage
	logic 								IF_pc_sel, IF_stall_en, IF_rst_n;
	logic 			[31 : 0]			IF_pc_imm;
	
	logic 			[31 : 0]			ID_inst, ID_pc, ID_pc_four;


//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// ID Stage
	logic 							ID_stall_en, ID_rst_n;

	logic			[31 : 0]				EX_rs1_data, EX_rs2_data;
	logic 			[31 : 0]			EX_pc, EX_pc_four;
	logic 			[31 : 0]			EX_imm_value;
	logic			[ 4 : 0]				EX_rs1_addr, EX_rs2_addr, EX_rd_addr;		// For forwarding control unit
	logic 			[ 4 : 0]			ID_rs1_addr, ID_rs2_addr;	// For forwarding control unit
	
	// For control signal
	logic 						EX_rd_wren;
	logic 			[15 : 0]		EX_ex_en;
	logic 			[8 : 0]			EX_mem_en;
	logic 			[1 : 0]			EX_wb_en;
	logic 						EX_rd_rs2_en;
	logic 						ID_rd_rs2_en;
	logic 						EX_ld_en;
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// EX Stage 
	logic 							EX_stall_en, EX_rst_n;
	
	logic 			[31 : 0]			MEM_alu_data;
	// For forwarding control unit 
	logic 			[4 : 0]			MEM_rd_addr;	
	logic 			[31 : 0]			MEM_rs2_data;											// For Store instruction
	logic 			[31 : 0]			MEM_pc_four;											// For jalr and jal inst that wb pc+4 into register

	// For control signal
	logic 							MEM_rd_wren;
	logic 			[8 : 0]				MEM_mem_en;
	logic 			[1 : 0]				MEM_wb_en;
	logic 							MEM_ld_en;
	
	// For Chosing PC address
	logic 							MEM_pc_br;
//////////////////////////////////////////////////////////////////////////
	
	
//////////////////////////////////////////////////////////////////////////
// MEM Stage 
	// Select pc for branch 
	logic 						MEM_stall_en, MEM_rst_n;
	
	logic						MEM_pc_sel;
	logic 			[31 : 0]		MEM_pc_imm;
	
	// Output for next stage
	logic 			[31 : 0]		WB_alu_data;
	logic 			[31 : 0]		WB_ld_data;	
	logic 			[31 : 0]		WB_pc_four;
	logic			[4 : 0]			WB_rd_addr;
	
	logic 						WB_rd_wren;
	logic 			[1 : 0]			WB_wb_en;
	logic 						WB_ld_en;
	
	assign                        MEM_stall_en 	= 1;
	assign                        MEM_rst_n 	= 1;
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// WB Stage
	logic 			[31 : 0]		wb_data;
	//logic									WB_pc_sel;
	logic 						WB_mem_wren;
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Forward control unit
	logic 		[1 : 0]				forwardA_en;
	logic			[1 : 0]				forwardB_en;
	logic			[31 : 0]				MEM_forwardA_data; 
	logic			[31 : 0]				MEM_forwardB_data;
	logic			[31 : 0]				WB_forwardA_data; 
	logic			[31 : 0]				WB_forwardB_data;
	
	//logic 								fw_pc_en;
	//logic									br_pc_en;
	logic									pc_en;
//	logic 					WB_rd_wren_check, WB_mem_wren_check;
//	logic 			[4 : 0]		WB_rd_addr_check;
	logic 					sel_rs1_wb, sel_rs2_wb;		
	
	assign		MEM_forwardA_data =	MEM_alu_data;
	assign		MEM_forwardB_data	=	MEM_alu_data;
	assign		WB_forwardA_data 	=	wb_data;
	assign		WB_forwardB_data	=	wb_data;
	
	

// Harzard_detector_unit
//	//logic 			[3 : 0]		rst_ni_state;
//	logic 					pc_en;
//	logic					br_j_harzard_en, raw_harzard_en;
//	logic 					MEM_br_j_harzard_en, MEM_raw_harzard_en;
//	logic                                   WB_br_j_harzard_en, WB_raw_harzard_en;
//	//assign			rst_ni_state	= {IF_rst_n, ID_rst_n, EX_rst_n, MEM_rst_n};
//	
//	//assign 			IF_pc_sel	=	MEM_pc_sel | WB_pc_sel;
//	assign         IF_pc_sel       =       MEM_pc_sel;
//	assign			IF_pc_imm	=	MEM_pc_imm;

// Control Forward Unit 
	assign			IF_pc_imm	=	MEM_pc_imm;
	assign         IF_pc_sel   	=  	MEM_pc_sel;
	
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////
////              Datapath 					////
//////////////////////////////////////////////

/////////////////
//  IF Stage  ///
///////////////// 
//===========================================================//
fetch_cycle 			IF_instance		(
// Input signal
						.clk_i			(clk_i), 
						.rst_ni			(rst_ni),
						
						.pc_sel			(IF_pc_sel),
						.pc_imm			(IF_pc_imm),
	
						.IF_stall_en		(IF_stall_en),
						.IF_rst_n		(IF_rst_n),	
	
						.pc_en			(pc_en),							// Always taken pc
						.ID_inst			(ID_inst),
						.ID_pc			(ID_pc), 
						.ID_pc_four		(ID_pc_four),
						.pc_debug_o		(pc_debug_o)
);
//===========================================================//



/////////////////
//  ID Stage  ///
///////////////// 
//===========================================================//
decode_cycle 			ID_instance		(
						.clk_i			(clk_i), 
						.rst_ni			(rst_ni),
						.WB_rd_wren		(WB_rd_wren),					// For regfile
						.ID_stall_en	(ID_stall_en),
						.ID_rst_n		(ID_rst_n),	
	
						.ID_inst			(ID_inst),
						.ID_pc			(ID_pc), 
						.ID_pc_four		(ID_pc_four),

						
						.WB_rd_addr		(WB_rd_addr),
						.WB_rd_data		(wb_data),
						.sel_rs1_wb		(sel_rs1_wb),
						.sel_rs2_wb		(sel_rs2_wb),

				
						.EX_rs1_data	(EX_rs1_data), 
						.EX_rs2_data	(EX_rs2_data),
						.EX_pc			(EX_pc), 
						.EX_pc_four		(EX_pc_four),
						.EX_imm_value	(EX_imm_value),

						// Forward for data write into regfile that is used 
						.ID_rs1_addr	(ID_rs1_addr),
						.ID_rs2_addr   (ID_rs2_addr),
						
						.EX_rs1_addr	(EX_rs1_addr), 
						.EX_rs2_addr	(EX_rs2_addr), 
						.EX_rd_addr		(EX_rd_addr),				// For forwarding control unit
		
	// For control signal
						.EX_rd_wren		(EX_rd_wren),
						.EX_ex_en		(EX_ex_en),
						.EX_mem_en		(EX_mem_en),
						.EX_wb_en		(EX_wb_en),
						.EX_rd_rs2_en		(EX_rd_rs2_en),
						.EX_ld_en		(EX_ld_en),
						.ID_rd_rs2_en		(ID_rd_rs2_en)
);

//===========================================================//



///////////////// 
//  EX Stage  ///
///////////////// 
//===========================================================//
execute_cycle 			EX_instance				(
						.clk_i					(clk_i), 
						.rst_ni					(rst_ni),
						.EX_stall_en			(EX_stall_en),
						.EX_rst_n				(EX_rst_n),

						.EX_rs1_data			(EX_rs1_data), 
						.EX_rs2_data			(EX_rs2_data),
						.EX_pc					(EX_pc), 
						.EX_pc_four				(EX_pc_four),
						.EX_imm_value			(EX_imm_value),
//						.EX_rs1_addr			(EX_rs1_addr), 
//						.EX_rs2_addr			(EX_rs2_addr), 
						.EX_rd_addr				(EX_rd_addr),		// For forwarding control unit
	
		// For forward Control Unit
	
						.forwardA_en			(forwardA_en), 
						.forwardB_en			(forwardB_en),
						.MEM_forwardA_data	(MEM_forwardA_data), 
						.MEM_forwardB_data	(MEM_forwardB_data),
						.WB_forwardA_data		(WB_forwardA_data), 
						.WB_forwardB_data		(WB_forwardB_data),
	
	// For control signal
						.EX_rd_wren				(EX_rd_wren),
						.EX_ex_en				(EX_ex_en),
						.EX_mem_en				(EX_mem_en),
						.EX_wb_en				(EX_wb_en),
						.EX_ld_en               (EX_ld_en),
	
						.MEM_alu_data			(MEM_alu_data),
	// For forwarding control unit 
//						.MEM_rs1_addr			(MEM_rs1_addr), 
//						.MEM_rs2_addr			(MEM_rs2_addr),
						.MEM_rd_addr			(MEM_rd_addr),	
						.MEM_rs2_data			(MEM_rs2_data),											// For Store instruction
						.MEM_pc_four			(MEM_pc_four),											// For jalr and jal inst that wb pc+4 into register

	// For control signal
						.MEM_rd_wren			(MEM_rd_wren),
						.MEM_mem_en				(MEM_mem_en),
						.MEM_wb_en				(MEM_wb_en),
	
	// For Chosing PC address
						.MEM_pc_br				(MEM_pc_br),
						.MEM_ld_en          			(MEM_ld_en)
//						.EX_pc_br				(EX_pc_br),
	// For harzard detector
//						.MEM_br_j_harzard_en			(MEM_br_j_harzard_en),
//						.MEM_raw_harzard_en			(MEM_raw_harzard_en)
);
//===========================================================//



/////////////////  
//  MEM Stage /// 
/////////////////
//===========================================================//
mem_cycle 				MEM_instance			(
						.clk_i				(clk_i), 
						.rst_ni				(rst_ni),
						.MEM_stall_en		(MEM_stall_en),
						.MEM_rst_n			(MEM_rst_n),
						.MEM_alu_data		(MEM_alu_data),
						.MEM_rs2_data		(MEM_rs2_data),											// For Store instruction
						.MEM_rd_addr		(MEM_rd_addr),											// For Reg write back address
						.MEM_pc_four		(MEM_pc_four),											// For jalr and jal inst that wb pc+4 into register
	
	// For control signal
						.MEM_rd_wren		(MEM_rd_wren),
						.MEM_mem_en			(MEM_mem_en),
						.MEM_wb_en			(MEM_wb_en),
						.MEM_ld_en               (MEM_ld_en),
	// For Chosing PC address
						.MEM_pc_br			(MEM_pc_br),
	// Input peripherals
						.sw					(io_sw_i), 
//				// For harzard detector
//						.MEM_raw_harzard_en		(MEM_raw_harzard_en),
//						.MEM_br_j_harzard_en		(MEM_br_j_harzard_en),
//	
	// Output 
	// Select pc for branch 
						.MEM_pc_sel			(MEM_pc_sel),
						.MEM_pc_imm			(MEM_pc_imm), 
	// Output peripherals
						.io_lcd				(io_lcd_o),
						.io_ledg				(io_ledg_o),
						.io_ledr				(io_ledr_o),
	
						.io_hex0				(io_hex0_o),
						.io_hex1				(io_hex1_o),
						.io_hex2				(io_hex2_o),
						.io_hex3				(io_hex3_o),
						.io_hex4				(io_hex4_o),
						.io_hex5				(io_hex5_o),
						.io_hex6				(io_hex6_o),
						.io_hex7				(io_hex7_o),
	
	
	// Output for next stage
						.WB_alu_data		(WB_alu_data),
						.WB_ld_data			(WB_ld_data),	
						.WB_pc_four			(WB_pc_four),
						.WB_rd_addr			(WB_rd_addr),
	
						.WB_rd_wren			(WB_rd_wren),
						.WB_mem_wren		(WB_mem_wren),
						.WB_wb_en			(WB_wb_en),
						.WB_ld_en               (WB_ld_en)
	//					.WB_pc_sel			(WB_pc_sel)
	//  For harzard detector
//						.WB_raw_harzard_en		(WB_raw_harzard_en), 
//						.WB_br_j_harzard_en		(WB_br_j_harzard_en)

);
//===========================================================//

///////////////// 
//  WB Stage  /// 
///////////////// 
wb_cycle				WB_instance 				(	
						//.clk_i						(clk_i), 
						//.rst_ni						(rst_ni),
						.WB_ld_data					(WB_ld_data), 
						.WB_alu_data				(WB_alu_data), 
						.WB_pc_four					(WB_pc_four),
						.WB_wb_en					(WB_wb_en),
						//.WB_rd_wren					(WB_rd_wren),
					       	//.WB_rd_addr				(WB_rd_addr),	
						//.WB_mem_wren				(WB_mem_wren),

						.wb_data				(wb_data)
						//.WB_rd_addr_check			(WB_rd_addr_check),
						//.WB_rd_wren_check			(WB_rd_wren_check), 
						//.WB_mem_wren_check			(WB_mem_wren_check)
);
//===========================================================//
	// Select data: pc_four, alu_data and ld_data into the regfile
//mux3to1_32bit			WB_instance		(
//							.a0			(WB_ld_data),
//							.a1			(WB_alu_data),
//							.a2			(WB_pc_four),
//							.sel			(WB_wb_en),			
//	
//							.s				(wb_data)
//);


//===========================================================//
// Module 1: Non-Forwarding 

// Hazard Detection unit
//harzard_detector_unit			detect_inst 			(
//// input
//								.rst_ni							(rst_ni),
//								.id_ex_memread					(EX_pc_br),				// Detect the branch or jump instruction in EX stage 
//								.wb_signal_at_wb_state		(WB_raw_harzard_en), 
//								.wb_signal_at_m_state		(MEM_raw_harzard_en),			// For non-branch instruction and jump
//								.brj_signal_at_wb_state		(WB_br_j_harzard_en), 
//								.brj_signal_at_m_state		(MEM_br_j_harzard_en),			// For non-branch instruction and jump
//								.rs_decode_addr				(ID_inst[24 : 15]),
//								.rd_ex_addr				(EX_rd_addr),
//	// output
//								.pc_write				(pc_en),
//								.if_id_write				(IF_stall_en),
//								.rst_ni_state				({IF_rst_n, ID_rst_n, EX_rst_n, MEM_rst_n}),		// MSB is Decoder -FF .... LSB is for WritBack -FF
//								.sel						(ID_ctr_sel),
//								.raw_harzard_en				(raw_harzard_en),
//								.br_j_harzard_en			(br_j_harzard_en)
//);	

//===========================================================//
// Module 2: Forwarding 
// Forward Control Unit 
forward_ctr_unit 		fwr_inst				(
// Input signal for Data Harzard without load instruction
							.MEM_rd_wren		(MEM_rd_wren), 
							.WB_rd_wren			(WB_rd_wren),
							//.WB_rd_wren_check	(WB_rd_wren_check),
	
// Input signal for Data Harzard with load instruction
							.MEM_mem_wren		(MEM_mem_en[0]),		// 1: write, 0: Read
							.WB_mem_wren      	(WB_mem_wren),
							.ID_rd_rs2_en           (ID_rd_rs2_en),
							.EX_rd_rs2_en		(EX_rd_rs2_en),
							.MEM_ld_en		(MEM_ld_en),
							.WB_ld_en		(WB_ld_en),
							//.WB_mem_wren_check	(WB_mem_wren_check),
			// Hardzard with regfile write signal after
			// instruction used it
							//.WB_rd_addr_check	(WB_rd_addr_check),
							.ID_rs2_addr    	(ID_rs2_addr),
                					.ID_rs1_addr    	(ID_rs1_addr),
							.EX_rs1_addr		(EX_rs1_addr), 
							.EX_rs2_addr		(EX_rs2_addr),
							.MEM_rd_addr		(MEM_rd_addr), 
							.WB_rd_addr		(WB_rd_addr),
					
	
// Ourput signal for select data
							.forwardA_en		(forwardA_en), 
							.forwardB_en		(forwardB_en),
							.sel_rs1_wb		(sel_rs1_wb),
							.sel_rs2_wb		(sel_rs2_wb),
// Output signal for hold and reset stage
	// Hold IF ID EX  and MEM stage 
							.IF_ID_en		(IF_stall_en), 
							.ID_EX_en		(ID_stall_en), 
							.EX_MEM_en		(EX_stall_en),
							//.MEM_WB_en			(MEM_stall_en),
							.pc_en			(pc_en),
	// Reset data from MEM stage 
							.EX_MEM_rst_n		(EX_rst_n)
);
// Branch Detection unit								
branch_detect_unit 	stage_rst_instance	(
// Signal for branch and jump detect
							.MEM_brj_en				(MEM_pc_sel),

// Output enable and reset for IF/ID, ID/EX and EX/MEM stage
							.IF_rst_n				(IF_rst_n),	
							.ID_rst_n				(ID_rst_n)
);

endmodule
