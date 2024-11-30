module mem_cycle (
// Input and output 
	input	logic								clk_i, 
	input	logic								rst_ni,
	input logic 							MEM_stall_en,
	input logic 							MEM_rst_n,
	input logic 			[31 : 0]		MEM_alu_data,
	input logic 			[31 : 0]		MEM_rs2_data,											// For Store instruction
	input logic 			[4 : 0]		MEM_rd_addr,											// For Reg write back address
	input logic 			[31 : 0]		MEM_pc_four,											// For jalr and jal inst that wb pc+4 into register
	
	// For control signal
	input logic 							MEM_rd_wren,
	input logic 			[8 : 0]		MEM_mem_en,
	input logic 			[1 : 0]				MEM_wb_en,
	input logic 						MEM_ld_en,
	// For Chosing PC address
	input logic 							MEM_pc_br,
	// Input peripherals
	input logic 			[31 : 0]		sw, 
	// For Harzard detection
//	input logic 						MEM_raw_harzard_en,
//	input logic                                             MEM_br_j_harzard_en,	
	// Output 
	// Select pc for branch 
	output logic							MEM_pc_sel,
	output logic 			[31 : 0]		MEM_pc_imm, 
	
	
	// Output peripherals
	output logic			[31 : 0] 	io_lcd,
	output logic			[31 : 0] 	io_ledg,
	output logic			[31 : 0] 	io_ledr,
	
	output logic			[31 : 0] 	io_hex0,
	output logic			[31 : 0] 	io_hex1,
	output logic			[31 : 0] 	io_hex2,
	output logic			[31 : 0] 	io_hex3,
	output logic			[31 : 0] 	io_hex4,
	output logic			[31 : 0] 	io_hex5,
	output logic			[31 : 0] 	io_hex6,
	output logic			[31 : 0] 	io_hex7,
	
	
	// Output for next stage
	output logic 			[31 : 0]		WB_alu_data,
	output logic 			[31 : 0]		WB_ld_data,	
	output logic 			[31 : 0]		WB_pc_four,
	output logic			[4 : 0]		WB_rd_addr,
	
	output logic 							WB_rd_wren,
	output logic 			[1 : 0]			WB_wb_en,
	// For harzard detector 
//	output logic 						WB_pc_sel,
	output logic						WB_mem_wren,
	output logic 						WB_ld_en
//	output logic                                             WB_raw_harzard_en,
//        output logic                                             WB_br_j_harzard_en
);

// Declaration of local logic
	// For branch and jump instruction 
	assign 		MEM_pc_sel 	= MEM_pc_br;
	assign		MEM_pc_imm	= MEM_alu_data;
	
	// LSU component 
	logic 		[31 : 0]		MEM_ld_data;
	
// Datapath 
//LSU component
dmem				dmem_inst		(
							.clk_i		(clk_i),	// positive clock.
							.rst_ni		(rst_ni),	// low negative reset
							.addr			(MEM_alu_data),	// the address for both read and write
							.st_data		(MEM_rs2_data),	// the store data
							.st_en		(MEM_mem_en[0]),	// 1 if write, 0 if read.
							.io_sw		(sw),		// 32-bit from switches
							.sb_en                  (MEM_mem_en[1]),
                     .sh_en                  (MEM_mem_en[2]),
							.sw_en                  (MEM_mem_en[3]),
                     .lb_en                  (MEM_mem_en[4]),
                     .lh_en                  (MEM_mem_en[5]),
                     .lbu_en                 (MEM_mem_en[6]),
                     .lhu_en                 (MEM_mem_en[7]),
							.lw_en                  (MEM_mem_en[8]),	
							.ld_data		(MEM_ld_data),	// the load data.
							.io_lcd		(io_lcd),	// 32-bit data to drive LCD.
							.io_ledg		(io_ledg),	// 32-bit data to drive green LEDs.
							.io_ledr		(io_ledr),	// 32-bit data to drive red LEDs.
							.io_hex0		(io_hex0),	// 32-bit data to drive 7-segment LEDs.
							.io_hex1		(io_hex1),
							.io_hex2		(io_hex2),
							.io_hex3		(io_hex3),
							.io_hex4		(io_hex4),
							.io_hex5		(io_hex5),
							.io_hex6		(io_hex6),
							.io_hex7		(io_hex7)
);
logic           rst_n;
assign          rst_n   = MEM_rst_n & rst_ni;
always @(posedge clk_i or negedge rst_n) begin
	if (!rst_n) begin
		WB_alu_data 	<= 0;
		WB_ld_data		<= 0;
		WB_pc_four		<= 0;
		WB_rd_addr		<= 0;
		
		WB_rd_wren		<= 0;
		WB_wb_en			<= 0;
//		WB_pc_sel		<= 0;
//		WB_raw_harzard_en	<= 0;
//        	WB_br_j_harzard_en		<= 0;
		WB_mem_wren		<=0;
		WB_ld_en		<= 0;
	end
	
	else if (MEM_stall_en) begin
		WB_alu_data 	<= MEM_alu_data;
		WB_ld_data		<= MEM_ld_data;
		WB_pc_four		<= MEM_pc_four;
		WB_rd_addr		<= MEM_rd_addr;
		
		WB_rd_wren		<= MEM_rd_wren;
		WB_wb_en			<= MEM_wb_en;
//		WB_pc_sel		<= MEM_pc_br;
		 WB_mem_wren             <= MEM_mem_en[0];
		 WB_ld_en		<= MEM_ld_en;
//		WB_raw_harzard_en       <= MEM_raw_harzard_en;
//                WB_br_j_harzard_en              <= MEM_br_j_harzard_en;
	end
	
	else begin
		WB_alu_data 	<= WB_alu_data;
		WB_ld_data		<= WB_ld_data;
		WB_pc_four		<= WB_pc_four;
		WB_rd_addr		<= WB_rd_addr;
		
		WB_rd_wren		<= WB_rd_wren;
		WB_wb_en			<= WB_wb_en;
//		WB_pc_sel		<= WB_pc_sel;
		WB_mem_wren		<= WB_mem_wren;
		WB_ld_en               <= WB_ld_en;
//		WB_raw_harzard_en       <= WB_raw_harzard_en;
//                WB_br_j_harzard_en              <= WB_br_j_harzard_en;
	end
end 
endmodule
