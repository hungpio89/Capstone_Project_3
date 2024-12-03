module Thesis_Project 
(
	input 	logic	[  9 :  0]	data_input,
	input 	logic					clk_i, 
	input		logic					UARTCLK,
	input		logic					rst_ni,
	
	output 	logic	[ 31 :  0]	pc_debug_o,
	output 	logic	[ 31 :  0] 	data_io_ledr_o,
	output	logic	[ 31 :  0]	data_out,
	
	// UART INTERFACE PORT
	input		logic					UART_RXD,
	output	logic					UART_TXD,
	
	// Delete later
	
//	output	reg	[ 31 :  0] 	HRDATA,
	output	logic	[ 31 :  0] 	PADDR
//	output	logic	[ 31 :  0] 	data_io_lcd_o
	
);
	// Local Signal Assignment
	reg				[ 31 :  0] 	HRDATA;
	
	logic				[ 31 :  0] 	data_io_lcd_o;
	logic				[ 31 :  0] 	data_io_ledg_o;
	logic				[ 31 :  0]	data_io_hex_0;
	logic				[ 31 :  0]	data_io_hex_1;
	logic				[ 31 :  0]	data_io_hex_2;
	logic				[ 31 :  0]	data_io_hex_3;
	logic				[ 31 :  0]	data_io_hex_4;
	logic				[ 31 :  0]	data_io_hex_5;
	logic				[ 31 :  0]	data_io_hex_6;
	logic				[ 31 :  0]	data_io_hex_7;
	
mux2to1_32bit							MUX_SELECT_HEX_DISPLAYMENT
(
	// INPUT LOGIC ASSIGNMENT
	
				.a								(HRDATA),
				.b								({24'b0, data_io_hex_1[3:0], data_io_hex_0[3:0]}),
				.sel							(data_input[9]),
					
	// OUTPUT LOGIC ASSIGNMENT
					
				.s								(data_out)
);	

pipeline_riscv_mod2 						PIPELINE_RISCV_MOD2
(
	// INPUT LOGIC ASSIGNMENT
	
				.io_sw_i						({24'b0, data_input[7:0]}),
				.clk_i						(clk_i), 
				.rst_ni						(rst_ni),
	
	// OUTPUT LOGIC ASSIGNMENT

				.pc_debug_o					(pc_debug_o),
				.io_lcd_o					(data_io_lcd_o),
				.io_ledg_o					(data_io_ledg_o),
				.io_ledr_o					({3'b0,data_io_ledr_o[31:3]}),
				.io_hex0_o					(data_io_hex_0),
				.io_hex1_o					(data_io_hex_1),
				.io_hex2_o					(data_io_hex_2),
				.io_hex3_o					(data_io_hex_3),
				.io_hex4_o					(data_io_hex_4),
				.io_hex5_o					(data_io_hex_5),
				.io_hex6_o					(data_io_hex_6),
				.io_hex7_o					(data_io_hex_7)	
);

//ram											RAM_BLOCK
//(
//	// INPUT LOGIC ASSIGNMENT
//	
//				.HCLK							(clk_i),
//				.HRESETn						(rst_ni),
//				.HWRITE						(io_lcd_o[31]),
//				.HTRANS						(io_lcd_o[30:29]),
//				.HSEL							(io_lcd_o[28]),
//				.HREADY						(io_lcd_o[27]),
//				.HWDATA						({16'b0, io_sw_i[15:0]}),
//	
//	// OUTPUT LOGIC ASSIGNMENT
//	
//				.HRDATA						(HRDATA),
//				.HREADYOUT					(io_ledr_o[0])
//	
//);

AHB_APB_UART 								AHB_APB_UART_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
				.HCLK							(clk_i),
				.HRESETn						(rst_ni),
				.HTRANS						(2'b11),						// Sequential
				.HWRITE						(data_input[9]),
				.HSIZES						(3'b000),					// Size used 8 bits length
				.HBURST						(3'b001),					// address increasingly 4
				.HSELABPif					(data_input[8]),
				.HREADYin					(1'b1),
				.HWDATA						(data_io_lcd_o),
				.UARTCLK						(UARTCLK),
				.desired_baud_rate		(20'h115200),
				.parity_bit_mode			(1'b1),
				.stop_bit_twice			(1'b1),
				.number_data_receive		(8'd8), 
				.number_data_trans		(8'd8),
				.ctrl_i						(7'b11),
				.state_isr					(2'b00),
				.uart_mode_clk_sel		(1'b1),
				.fifo_en						(2'b11),
	
	// OUTPUT LOGIC CONFIGURATION
	
				.HREADYout					(data_io_ledr_o[0]),
				.HRESP						(data_io_ledr_o[2:1]),
				.HRDATA						(HRDATA),
				.UART_RXD					(UART_RXD),
				.UART_TXD					(UART_TXD),
				
	// Delete later
				.PADDR						(PADDR)
);

endmodule
