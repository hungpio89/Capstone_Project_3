module wrapper (										// Overall assignment for FPGA DE-10 interface
  // inputs
  input  logic [ 9 : 0] SW,
  input	logic [ 3 : 0] KEY,

  input  logic        	CLOCK_50,
  input  logic        	CLOCK2_50,
  
  // outputs
  output						GPIO_RX_sub,			// GPIO[3] 		-- AK3
  input	logic 			GPIO_i,					// GPIO[0]		-- RX (from UART)
  output logic				GPIO_o,					// GPIO[1]
  output	logic				GPIO_clk,				// GPIO[2]
  
  output logic [ 9 : 0] LEDR,

  output logic [ 6 : 0] HEX0,
  output logic [ 6 : 0] HEX1,
  output logic [ 6 : 0] HEX2,
  output logic [ 6 : 0] HEX3,
  output logic [ 6 : 0] HEX4,
  output logic [ 6 : 0] HEX5
  
);

	logic	[ 31 :  0] 		HRDATA;
	logic	[ 31 :  0] 		HADDR;
	logic	[ 31 :  0] 		data_io_lcd_o;
	logic	[ 31 :  0] 		pc_debug_o;
	logic	[ 31 :  0]		data_out;
	
	logic						UARTCLK;
	
	assign GPIO_RX_sub	= GPIO_i;

clock_divider 				CLOCK_DIVIDER_BLOCK(
		.clk_in				(CLOCK2_50),   	// Clock đầu vào (50 MHz)
		.rst_n				(KEY[0]),    		// Reset tín hiệu âm
		.clk_out				(UARTCLK)   	// Clock đầu ra (10 MHz)
);

clock_generator_40us 	CLOCK_DIVIDER_BLOCK_40US(
		.clk_in				(CLOCK2_50),   	// Clock đầu vào (50 MHz)
		.rst_n				(KEY[0]),    		// Reset tín hiệu âm
		.clk_out				() 
);

button_debounce 			BUTTON_DEBOUNCE_RX(
		.clk					(CLOCK2_50),          // Clock 50 MHz
		.rst_n				(KEY[0]),        		// Reset (active low)
		.button_in			(KEY[2]),    			// Tín hiệu đầu vào từ nút bấm
		.button_out			()   				// Tín hiệu đầu ra đã chống rung
);

button_debounce 			BUTTON_DEBOUNCE_SEND(
		.clk					(CLOCK_50),          // Clock 50 MHz
		.rst_n				(KEY[0]),        // Reset (active low)
		.button_in			(KEY[1]),    // Tín hiệu đầu vào từ nút bấm
		.button_out			(ctrl_send)  // Tín hiệu đầu ra đã chống rung
);

Thesis_Project 			THESIS_PROJECT_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
		.data_input			(SW[9:0]),
		.clk_i				(CLOCK_50), 
		.UARTCLK				(UARTCLK),
		.rst_ni				(KEY[0]),
		.ctrl_send			(ctrl_send),
			
	// OUTPUT LOGIC ASSIGNMENT
	
		.data_io_ledr_o	(LEDR[9:0]),
		.data_out			(data_out),
			
	// UART INTERFACE PORT
		.UART_RXD			(GPIO_i),
		.UART_TXD			(GPIO_o),
			
	// Delete later
		.baud_tick			(GPIO_clk),
		.data_io_lcd_o		(data_io_lcd_o)
);
//
//BAUD_RATE_GENERATOR 				BAUD_RATE_GENERATOR_BLOCK_TEST_ONLY
//(
//	// INPUT LOGIC CONFIGURATION
//	
//		.uart_ref_clk			(clock_10MHz),        
//		.rst_n					(KEY[0]),      		
//		.uart_mode_sel			(1'b0),
//		.baud_div_16			(clock_10MHz),     
//		.cd						(13'd27),
//
//	// OUTPUT LOGIC CONFIGURATION
//	
//		.baud_tick 				()
//);

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
