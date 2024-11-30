module AHB_APB_UART 
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic 					HCLK,						// input clk_i from CPU (interface with rising-edge).
	input logic 					HRESETn,					// input rst_ni from CPU.
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  1 :  0]	HTRANS,					// This indicates the type of the current transfer, which can be NONSEQUENTIAL, SEQUENTIAL, IDLE or BUSY.
	input logic 					HWRITE,					// indicates an AHB write ACCESS when HIGH (1) and an AHB read ACCESS when LOW (0).
//	
//																	// indicates that the current transfer is intended for the selected.
//																	// slave. This signal is a combinatorial decode of the address bus.	
	input logic 					HREADYin,				// When HIGH the HREADY signal indicates that a transfer has
																	// finished on the bus. This signal may be driven LOW to extend a transfer.
	input logic		[ 31 :  0]	HWDATA,
	input logic		[ 31 :  0]	HADDR,					// The 32-bit system address bus.
	//---------------------------------------------------//
	
	//--------EXTERNAL CONFIGURATION FROM MASTER---------//
	input logic						UARTCLK,
	input logic		[ 19 :  0]	desired_baud_rate,
	input logic 					parity_bit_mode,
	input logic						stop_bit_twice,
	input logic		[  3 :  0]	number_data_receive, 
	input logic		[  3 :  0]	number_data_trans,
	input logic		[	6 :  0]	ctrl_i,
	input logic		[  1 :  0]	state_isr,
	input logic 					uart_mode_clk_sel,
	input logic		[  1 :  0]	fifo_en,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	// SEND TO SLAVE
	output logic 					HREADYout,
	output logic 	[  1 :  0]	HRESP,
	//---------------------------------------------------//
	
	//-----------------SEND BACK TO MASTER---------------//
	output logic	[ 31 :  0]	HRDATA,
	//---------------------------------------------------//
	
	//------------------UART INTERFACE-------------------//
	input  logic 					UART_RXD,
	output logic 					UART_TXD 
	//---------------------------------------------------//
	
	//---------------------UART FLAG---------------------//
//	output logic   [ 31 :  0]	UART_FLAG,
	//---------------------------------------------------//
);

	// Local signal assignment
	reg	[ 31 :  0]	PRDATA;
	reg	[ 31 :  0]	PWDATA;
	reg	[ 31 :  0]	PADDR;
	
	logic 				PENABLE;					// indicates second and subsequent cycles of an APB transfer.
	logic 				PSELx;
	logic					PREADY;
	logic 				PWRITE;					// indicates an APB write ACCESS when HIGH (1) and an APB read ACCESS when LOW (0).

AHB_SLAVE 							AHB_APB_BRIDGE
(
	// INPUT LOGIC ASSIGNMENT
										.HCLK						(HCLK),
										.HRESETn					(HRESETn),
										.HTRANS					(HTRANS),
										.HWRITE					(HWRITE),
										.HREADYin				(HREADYin),
										.HWDATA					(HWDATA),
										.HADDR					(HADDR),
										.PRDATA					(PRDATA),
										.PREADY					(PREADY),
										
	// OUTPUT LOGIC CONFIGURATION

										.PWDATA					(PWDATA),
										.PADDR					(PADDR),
										.PENABLE					(PENABLE),
										.PWRITE					(PWRITE),					
										.HREADYout				(HREADYout),
										.HRESP					(HRESP),
										.PSELx					(PSELx),
										.HRDATA					(HRDATA)
);

APB_UART								APB_UART_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
										.PCLK						(HCLK),
										.UARTCLK					(UARTCLK),
										.PRESETn					(HRESETn),
										.desired_baud_rate	(desired_baud_rate),
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.fifo_en					(fifo_en),
										.number_data_receive	(number_data_receive), 
										.number_data_trans	(number_data_trans),
										.ctrl_i					(ctrl_i),
										.state_isr				(state_isr),
										.uart_mode_clk_sel	(uart_mode_clk_sel),
										.PSEL						(PSELx),
										.PENABLE					(PENABLE),
										.PWRITE					(PWRITE),
										.PADDR					(PADDR[11:0]),
										.PWDATA					(PWDATA[7:0]),
	
	//OUTPUT LOGIC ASSIGNMENT
	
										.PREADY					(PREADY),
										.PRDATA					(PRDATA),
										
	// UART INTERFACE PORT
										.UART_RXD				(UART_RXD),
										.UART_TXD				(UART_TXD)
);

endmodule
