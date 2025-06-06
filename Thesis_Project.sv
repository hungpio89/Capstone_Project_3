module Thesis_Project 
(
	input 	logic					clk_i, 
	input		logic					UARTCLK,
	input		logic					rst_ni,
	
	input		logic					ctrl_send,
	
	input 	logic	[  9 :  0]	data_input,
	
	output 	logic	[ 31 :  0] 	data_io_ledr_o,
	output	logic	[ 31 :  0]	data_out,
	
	// UART INTERFACE PORT
	input		logic					UART_RXD,
	output	logic					UART_TXD,
	
	// Delete later
	output 	logic					baud_tick,
	output	logic	[ 31 :  0] 	data_io_lcd_o
	
);
	// Local Signal Assignment
	
	logic				[ 31 :  0]	pc_debug_o;
	
	logic				[ 31 :  0] 	data_to_uart_i;
	logic				[ 31 :  0] 	data_io_ledg_o;
	logic				[ 31 :  0]	data_io_hex_0;
	logic				[ 31 :  0]	data_io_hex_1;
	logic				[ 31 :  0]	data_io_hex_2;
	logic				[ 31 :  0]	data_io_hex_3;
	logic				[ 31 :  0]	data_io_hex_4;
	logic				[ 31 :  0]	data_io_hex_5;
	logic				[ 31 :  0]	data_io_hex_6;
	logic				[ 31 :  0]	data_io_hex_7;
	
	
	reg   			[  9 :  0]	UART_ERROR_FLAG;
	reg				[ 31 :  0] 	HRDATA;
	reg				[ 31 :  0] 	HADDR;
	
mux2to1_32bit								MUX_SELECT_HEX_DISPLAYMENT
(
	// INPUT LOGIC ASSIGNMENT
	
				.a								(HRDATA),
				.b								({8'b0, data_io_hex_5[3:0], data_io_hex_4[3:0], data_io_hex_3[3:0], data_io_hex_2[3:0], data_io_hex_1[3:0], data_io_hex_0[3:0]}),
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
//				.HWRITE						(data_input[9]),
//				.HTRANS						(2'b11),
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

D_FF_32bit									D_FF_32_BIT_FOR_SEND_TO_UART
(
				.D								(data_io_lcd_o),
				.clk							(clk_i), 
				.rst_ni						(rst_ni), 
				.en							(ctrl_send),
				.Q								(data_to_uart_i)
);

AHB_APB_UART 								AHB_APB_UART_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
				.HCLK							(clk_i),
				.HRESETn						(rst_ni),
				.HTRANS						(2'b11),						// Sequential
				.HWRITE						(data_input[9]),
				.HSIZES						(2'b00),						// Size used 8 bits length
				.HBURST						(3'b001),					// address increasingly 4
				.HSELABPif					(data_input[8]),
				.HREADYin					(1'b1),
				.HWDATA						(data_io_lcd_o),			
				.UARTCLK						(UARTCLK),					// External Clock
				.desired_baud_rate		(20'h115200),				// Baudrate used is 115200 bits/sec
				.parity_bit_mode			(1'b1),
				.stop_bit_twice			(1'b1),
				.number_data_receive		(8'd8), 
				.number_data_trans		(8'd8),
				.ctrl_i						(7'b11),
				.state_isr					(2'b00),
				.uart_mode_clk_sel		(1'b0),						// Let FPGA to divide clock
				.fifo_en						(2'b11),						// Enable FIFO full ON
	
	// OUTPUT LOGIC CONFIGURATION
	
				.HREADYout					(data_io_ledr_o[0]),			// HREADYout
				.HRESP						(data_io_ledr_o[2:1]),		// HRESP
				.HRDATA						(HRDATA),
				.UART_RXD					(UART_RXD),
				.UART_TXD					(UART_TXD),
				.UART_ERROR_FLAG			(UART_ERROR_FLAG),
				.HADDR						(HADDR),
				
	// Delete later
				.baud_tick					(baud_tick)
);

endmodule
