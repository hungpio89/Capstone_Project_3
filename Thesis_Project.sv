module Thesis_Project 
(
	input 	logic	[31 : 0]		io_sw_i,
	input 	logic					clk_i, 
	input		logic					UARTCLK,
	input		logic					rst_ni,
	
	output 	logic	[31 : 0]		pc_debug_o,
	output 	logic	[31 : 0] 	io_lcd_o,
	output 	logic	[31 : 0] 	io_ledg_o,
	output 	logic	[31 : 0] 	io_ledr_o,
	output 	logic	[31 : 0] 	io_hex0_o,
	output 	logic	[31 : 0] 	io_hex1_o,
	output 	logic	[31 : 0] 	io_hex2_o,
	output 	logic	[31 : 0]		io_hex3_o,
	output 	logic	[31 : 0] 	io_hex4_o,
	output 	logic	[31 : 0] 	io_hex5_o,
	output 	logic	[31 : 0]		io_hex6_o,
	output 	logic	[31 : 0] 	io_hex7_o	
);

	reg 				[31 : 0] 	HRDATA;	
	
pipeline_riscv_mod2 					PIPELINE_RISCV_MOD2
(
	// INPUT LOGIC ASSIGNMENT
	
				.io_sw_i						(io_sw_i),
				.clk_i						(clk_i), 
				.rst_ni						(rst_ni),
	
	// OUTPUT LOGIC ASSIGNMENT

				.pc_debug_o					(pc_debug_o),
				.io_lcd_o					(io_lcd_o),
				.io_ledg_o					(io_ledg_o),
				.io_ledr_o					(io_ledr_o),
				.io_hex0_o					(HRDATA[ 3: 0]),
				.io_hex1_o					(HRDATA[ 7: 4]),
				.io_hex2_o					(HRDATA[11: 8]),
				.io_hex3_o					(HRDATA[15:12]),
				.io_hex4_o					(HRDATA[19:16]),
				.io_hex5_o					(HRDATA[23:20]),
				.io_hex6_o					(HRDATA[27:24]),
				.io_hex7_o					(HRDATA[31:28])	
);

ram											RAM_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
				.HCLK							(clk_i),
				.HRESETn						(rst_ni),
				.HWRITE						(io_lcd_o[31]),
				.HTRANS						(io_lcd_o[30:29]),
				.HSEL							(io_lcd_o[28]),
				.HREADY						(io_lcd_o[27]),
				.HWDATA						({16'b0, io_sw_i[15:0]}),
	
	// OUTPUT LOGIC ASSIGNMENT
	
				.HRDATA						(HRDATA),
				.HREADYOUT					(io_ledr_o[0])
	
);

AHB_APB_UART 								AHB_APB_UART_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
				.HCLK							(clk_i),
				.HRESETn						(rst_ni),
				.HTRANS						(HTRANS),
				.HWRITE						(io_lcd_o[31]),
				.HSIZES						(io_lcd_o[26:24]),
				.HBURST						(io_lcd_o[23:21]),
				.HSELABPif					(io_lcd_o[20]),
				.HREADYin					(io_lcd_o[19]),
				.HWDATA						({16'b0, io_sw_i[15:0]}),
				.UARTCLK						(UARTCLK),
				.desired_baud_rate		(20'h9600),
				.parity_bit_mode			(1'b1),
				.stop_bit_twice			(1'b1),
				.number_data_receive		(8'd8), 
				.number_data_trans		(8'd8),
				.ctrl_i						(7'b11),
				.state_isr					(2'b00),
				.uart_mode_clk_sel		(1'b0),
				.fifo_en						(2'b11),
	
	// OUTPUT LOGIC CONFIGURATION
	
				.HREADYout					(io_ledr_o[1]),
				.HRESP						(io_ledr_o[3:2]),
				.HRDATA						(HRDATA),
				.UART_RXD					(UART_RXD),
				.UART_TXD					(UART_TXD) 
);

endmodule
