module wrapper (										// Overall assignment for FPGA DE-10 interface
  // inputs
  input  logic [ 9 : 0] SW,
  input	logic [ 3 : 0] KEY,
  input  logic        	CLOCK_50,
  input  logic        	CLOCK2_50,
  // outputs
  input  logic 			GPIO_i,
  output logic				GPIO_o,
  
  output logic [ 9 : 0] LEDR,

  output logic [ 6 : 0] HEX0,
  output logic [ 6 : 0] HEX1
);

	logic	[ 31 :  0] 		HRDATA;
	logic	[ 31 :  0] 		HADDR;
	logic	[ 31 :  0] 		data_io_lcd_o;
	logic	[ 31 :  0] 		pc_debug_o;
	logic	[ 31 :  0]		data_out;

Thesis_Project 			THESIS_PROJECT_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
		.data_input			(SW[9:0]),
		.clk_i				(CLOCK_50), 
		.UARTCLK				(CLOCK2_50),
		.rst_ni				(KEY[0]),
			
	// OUTPUT LOGIC ASSIGNMENT
	
		.data_io_ledr_o	(LEDR[9:0]),
		.data_out			(data_out),
			
	// UART INTERFACE PORT
		.UART_RXD			(GPIO_i),
		.UART_TXD			(GPIO_o),
			
	// Delete later
		.data_io_lcd_o		(data_io_lcd_o)
);

// 7-segment display assignment

bcdtohex						HEX0_DISPLAY
(
		.bcd					(data_out[3:0]),
		.segment				(HEX0)
);

bcdtohex						HEX1_DISPLAY
(
		.bcd					(data_out[7:4]),
		.segment				(HEX1)
);

bcdtohex						HEX2_DISPLAY
(
		.bcd					(data_out[11:8]),
		.segment				(HEX2)
);

bcdtohex						HEX3_DISPLAY
(
		.bcd					(data_out[15:12]),
		.segment				(HEX3)
);

bcdtohex						HEX4_DISPLAY
(
		.bcd					(data_out[19:16]),
		.segment				(HEX4)
);

bcdtohex						HEX5_DISPLAY
(
		.bcd					(data_out[23:20]),
		.segment				(HEX5)
);

endmodule : wrapper
