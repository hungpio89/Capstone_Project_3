module wb_cycle (
//input logic 					clk_i, rst_ni,
input logic 	[31 : 0]		WB_ld_data, WB_alu_data, WB_pc_four,
input logic 	[1 : 0]				WB_wb_en,
//input logic	[4 : 0]				WB_rd_addr, 					
//input logic 					WB_rd_wren, WB_mem_wren,

output logic 	[31 : 0]	   wb_data
//output logic 	[4 : 0]				WB_rd_addr_check,
//output logic					WB_rd_wren_check, WB_mem_wren_check
);

	// Select data: pc_four, alu_data and ld_data into the regfile
mux3to1_32bit			select_inst	(
							.a0			(WB_ld_data),
							.a1			(WB_alu_data),
							.a2			(WB_pc_four),
							.sel			(WB_wb_en),			
	
							.s				(wb_data)
);
	//mem_wren 1: write, 0: Read
	//rd_wren  1: write, 0: Read
//always @(posedge clk_i or negedge rst_ni) begin
//	if (!rst_ni) begin
//		WB_rd_wren_check 		<=	0;		
//		WB_mem_wren_check		<=	1;
//		WB_rd_addr_check		<=	0;
//	end
	
//	else begin
//		WB_rd_wren_check 		<=	WB_rd_wren;
//		WB_rd_addr_check		<=	WB_rd_addr;
//		WB_mem_wren_check		<=	WB_mem_wren;
//	end
//end
endmodule
