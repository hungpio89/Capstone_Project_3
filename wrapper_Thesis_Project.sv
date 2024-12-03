module wrapper_Thesis_Project
(
	// inputs
	input  logic [9:0] 	SW,
	input  logic        	CLOCK_50,
	input	 logic [3:0]	KEY,
	// outputs
	output logic [9:0] 	LEDR,

	output logic [6 :0] 	HEX0,
	output logic [6 :0] 	HEX1,
	output logic [6 :0] 	HEX2,
	output logic [6 :0] 	HEX3,
	output logic [6 :0] 	HEX4,
	output logic [6 :0] 	HEX5,
	output logic [6 :0] 	HEX6,
	output logic [6 :0] 	HEX7,
	
	output logic [35:34] GPIO
);
	logic			[31:0] data_to_hex;
	logic			[31:0] pc_debug_o;
//	logic			[31:0] HRDATA;
	logic			[31:0] PADDR;

Thesis_Project 					THESIS_PROJECT_BLOCK
(
		.data_input					(SW),
		.clk_i						(CLOCK_50), 
		.UARTCLK						(CLOCK2_50),
		.rst_ni						(KEY[0]),
			
		.pc_debug_o					(pc_debug_o),
		.data_io_ledr_o			({22'b0, LEDR}),
		.data_out					(data_to_hex),
			
			// UART INTERFACE PORT
		.UART_RXD					(),
		.UART_TXD					(GPIO[35]),
			
			// Delete later
			
//		.HRDATA						(HRDATA),
		.PADDR						(PADDR)
//		.data_io_lcd_o				()
	
);

decode_hex 			hex0_inst (
				.hex_digit		(data_to_hex[3 : 0]),
				.segment			(HEX0)
);		

decode_hex 			hex1_inst (
				.hex_digit		(data_to_hex[7 : 4]),
				.segment			(HEX1)
);	

decode_hex 			hex2_inst (
				.hex_digit		(data_to_hex[11 : 8]),
				.segment			(HEX2)
);	

decode_hex 			hex3_inst (
				.hex_digit		(data_to_hex[15 : 12]),
				.segment			(HEX3)
);	

decode_hex 			hex4_inst (
				.hex_digit		(data_to_hex[19 : 16]),
				.segment			(HEX4)
);	

decode_hex 			hex5_inst (
				.hex_digit		(data_to_hex[23 : 20]),
				.segment			(HEX5)
);	

decode_hex 			hex6_inst (
				.hex_digit		(data_to_hex[27 : 24]),
				.segment			(HEX6)
);	

decode_hex 			hex7_inst (
				.hex_digit		(data_to_hex[31 : 28]),
				.segment			(HEX7)
);		

endmodule	