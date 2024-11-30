module wrapper_mod2 (
  // inputs
  input  logic [16:0] SW,
  input  logic        CLOCK_50,
  // outputs
  output logic [16:0] LEDR,
  output logic [7 :0] LEDG,

  output logic [6 :0] HEX0,
  output logic [6 :0] HEX1,
  output logic [6 :0] HEX2,
  output logic [6 :0] HEX3,
  output logic [6 :0] HEX4,
  output logic [6 :0] HEX5,
  output logic [6 :0] HEX6,
  output logic [6 :0] HEX7,

  output logic [7 :0] LCD_DATA,
  output logic 	    LCD_RW,
  output logic        LCD_EN,
  output logic        LCD_RS,
  output logic        LCD_ON
);

	logic 	      		pc_debug;
	logic 	[31 : 0]		io_hex0_o;
	logic 	[31 : 0]		io_hex1_o;
	logic 	[31 : 0]		io_hex2_o;
	logic 	[31 : 0]		io_hex3_o;
	logic 	[31 : 0]		io_hex4_o;
	logic 	[31 : 0]		io_hex5_o;
	logic 	[31 : 0]		io_hex6_o;
	logic 	[31 : 0]		io_hex7_o;
	

 pipeline_riscv_mod2 dut 	(
	  .io_sw_i	({15'b0, SW[15 : 0]}),
	  .clk_i		(CLOCK_50),
	  .rst_ni	(SW[16]),

	  .pc_debug_o	(pc_debug),
	  .io_lcd_o	({LCD_ON, 19'b0, LCD_EN, LCD_RS, LCD_RW, LCD_DATA}),
	  .io_ledg_o	({23'b0, LEDG}),
	  .io_ledr_o	({14'b0, LEDR}),
	  .io_hex0_o	 (io_hex0_o),
	  .io_hex1_o    (io_hex1_o),
	  .io_hex2_o    (io_hex2_o),
	  .io_hex3_o    (io_hex3_o),
	  .io_hex4_o    (io_hex4_o),
	  .io_hex5_o    (io_hex5_o),
	  .io_hex6_o    (io_hex6_o),
	  .io_hex7_o    (io_hex7_o)
  );
  
decode_hex 			hex0_inst (
				.hex_digit		(io_hex0_o[3 : 0]),
				.segment			(HEX0)
);		

decode_hex 			hex1_inst (
				.hex_digit		(io_hex1_o[3 : 0]),
				.segment			(HEX1)
);	

decode_hex 			hex2_inst (
				.hex_digit		(io_hex2_o[3 : 0]),
				.segment			(HEX2)
);	

decode_hex 			hex3_inst (
				.hex_digit		(io_hex3_o[3 : 0]),
				.segment			(HEX3)
);	

decode_hex 			hex4_inst (
				.hex_digit		(io_hex4_o[3 : 0]),
				.segment			(HEX4)
);	

decode_hex 			hex5_inst (
				.hex_digit		(io_hex5_o[3 : 0]),
				.segment			(HEX5)
);	

decode_hex 			hex6_inst (
				.hex_digit		(io_hex6_o[3 : 0]),
				.segment			(HEX6)
);	

decode_hex 			hex7_inst (
				.hex_digit		(io_hex7_o[3 : 0]),
				.segment			(HEX7)
);		

endmodule : wrapper_mod2
