module fetch_cycle (
// Input signal
	input	logic							clk_i, 
	input	logic							rst_ni,
	
	input logic							pc_sel,
	input logic 	[31 : 0]			pc_imm,
	
	input logic 						IF_stall_en,
	input logic 						IF_rst_n,
	input logic 						pc_en,					// Hold the PC
	
	output logic	[31 : 0]			ID_inst,
	output logic 	[31 : 0]			ID_pc, ID_pc_four,
	output logic 	[31 : 0]			pc_debug_o
);

// Declaration local wire
	logic 			[31 : 0]		nxt_pc, pc;
	logic				[31 : 0]		pc_four;
	logic 			[31 : 0]		inst;	
	
//	logic				[31 : 0]		ID_pc, ID_inst;	
	
//	logic 							br_sel					// From Branch Prediction - Select PC (0 - PC + 4, 1 - PC + imm (b-type, j-type))
//	logic 							pc_wr;					// From Harzard Detector Unit - Non Forwarding - Hold the PC counter (0 - Hold, 1 - Release)
//	logic 							IF_en						// From Harzard Detector Unit - Non Forwarding - Hold the data from IF/ID reg (0 - Hold, 1 - Release)
//	logic 							IF_rst_n					// Reset the data in IF register
	
	assign 			pc_debug_o	= pc;
	
// Datapath 
D_FF_32bit			PC_inst			(
							.D				(nxt_pc),
							.clk			(clk_i),
							.rst_ni		(rst_ni),
							.en			(pc_en),
							.Q				(pc)
);

			// Generating pc_four
adder_32bit 			FA_inst			(
							.a				(pc),
							.b				(32'b0100),       
							.cin			(1'b0),           
							.s				(pc_four)      
);	

			// Select br_sel
mux2to1_32bit			Mux_br_sel			(
							.a				(pc_four),
							.b				(pc_imm),
							.sel			(pc_sel),
							.s				(nxt_pc)
);
			// Instruction memory (IMEM) component
imem					i_inst			(
							.addr			(pc),
							.rst_ni			(rst_ni),
							.inst			(inst)
);

// IF/ID Pipeline stage
logic           rst_n;
assign          rst_n   = IF_rst_n & rst_ni;
always @(posedge clk_i or negedge rst_n) begin
	if (!rst_n) begin
		ID_inst 	<= 0;
		ID_pc		<= 0;
		ID_pc_four	<= 0;
	end
	
	else if (IF_stall_en) begin
		ID_inst 	<= inst;
		ID_pc		<= pc;
		ID_pc_four	<= pc_four;
	end
	
	else begin
		ID_inst 		<= ID_inst;
		ID_pc			<= ID_pc;
		ID_pc_four	<= ID_pc_four;
	end
end
endmodule
