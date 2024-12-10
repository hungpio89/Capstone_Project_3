module wrapper (
  // inputs
  input  logic [ 9 : 0] SW,
  input	logic [ 3 : 0] KEY,
  input  logic        	CLOCK_50,
  input  logic				EXT_CLOCK,
  // outputs
  input  logic [ 1 : 0] GPIO,
  
  output logic [ 9 : 0] LEDR,

  output logic [ 6 : 0] HEX0,
  output logic [ 6 : 0] HEX1
);

	logic	[ 31 :  0] 		HRDATA;

AHB_APB_UART dut(
		.HCLK						(CLOCK_50),
		.HRESETn					(KEY[0]),
		.UARTCLK					(EXT_CLOCK),
	  
		.HTRANS					(SW[8:7]),
		.HWRITE					(SW[9]),
		.HREADYin				(1'b1),
		.HWDATA					({28'b0, SW[3:0]}),
		.HADDR					({27'h800004,SW[6],SW[5],SW[4],2'h0}),
		.HRDATA					(HRDATA),
		.HREADYout				(LEDR[9]),
		.HRESP					(LEDR[1:0]),
		.UART_RXD				(GPIO[0]),
		.UART_TXD				(GPIO[1]),
		
		.desired_baud_rate  	(20'd921600),
		.parity_bit_mode    	(1'b1),
		.stop_bit_twice     	(1'b1),
		.number_data_receive	(4'd8), 
		.number_data_trans	(4'd8),
		.ctrl_i         		(7'd3),
		.state_isr         	(2'b0),
		.uart_mode_clk_sel   (1'b0),
		.fifo_en         		(2'b10)
);

bcdtohex						HEX0_DISPLAY
(
		.bcd					(HRDATA[3:0]),
		.segment				(HEX0)
);

bcdtohex						HEX1_DISPLAY
(
		.bcd					(HRDATA[7:4]),
		.segment				(HEX1)
);


endmodule : wrapper
