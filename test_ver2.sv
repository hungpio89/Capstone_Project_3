module test_ver2												// Wrapping APB UART OPERATING BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic						UARTCLK,					// this is considered as the external custom clock by user
	input logic						PRESETn,
	input logic 					parity_bit_mode,
	//---------------------------------------------------//
	//---------------APB BRIDGE INPUT--------------------//
	input logic						PWRITE,
	input logic [  7 :   0] 	PWDATA,					// reference is 16 bit, currently use 32 bit (don't know reason why use 16 only)
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//---------------------------------------------------//
	//-----------------UART external port----------------//
	output logic 					UART_TXD,
	//---------------------------------------------------//
	
	// For simulation only (delete later) -> if not use move to local assignment signal
	output reg 	 [  7 :   0] 	tx_fifo_o, temp,
	output logic					TXdone, ctrl_tx_buffer,
	output logic [  3 :   0]	ctrl_shift_register,
	output logic [  3 :   0] 	tick_count,
	output reg   [  3 :   0] 	tx_fifo_wr_ptr,
	output reg   [  3 :   0] 	tx_fifo_rd_ptr,
	output logic					start_bit, data_avail, data_on_trans, parity_bit, stop_bit
	//---------------------------------------------------//
);	


	reg [  7 :  0] tx_fifo_mid;

//---------------------------------------------------//
tx_fsm								TX_FSM_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PRESETn					(PRESETn),
										.parity_bit_mode		(parity_bit_mode),
										.baud_tick				(UARTCLK),
										.start_bit				(start_bit),
										.data_avail				(data_avail),
										.data_on_trans			(data_on_trans),
										.parity_bit				(parity_bit),
										.stop_bit				(stop_bit),
										
	// OUTPUT LOGIC CONFIGURATION
										.ctrl_shift_register	(ctrl_shift_register),
										.ctrl_tx_buffer		(ctrl_tx_buffer),
										.tick_count				(tick_count),
										.done_tx					(TXdone)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_8bit							DFF_TEMPORARY_STORING_WRITE
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick				(UARTCLK), 
										.rst_ni					(PRESETn), 
										.enable					(ctrl_tx_buffer),
										.D							(tx_fifo_o),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q							(temp)
);
//---------------------------------------------------//

//---------------------------------------------------//
shift_register						SHIFT_REGISTER_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.parity_bit_mode		(parity_bit_mode),
										.ctrl_shift_register	(ctrl_shift_register),
										.data_in					(temp),
										.tick_count				(tick_count),
										
	// OUTPUT LOGIC CONFIGURATION
										.start_bit				(start_bit),
										.data_avail				(data_avail),
										.data_on_trans			(data_on_trans),
										.parity_bit				(parity_bit),
										.stop_bit				(stop_bit),
										.tx_out					(UART_TXD)
);
//---------------------------------------------------//

//---------------------------------------------------//
transmit_FIFO						TX_FIFO_BLOCK
(
	// INPUT LOGIC CONFIGURATION
//										.wr_en					(PWRITE), 
										.clk_i					(UARTCLK), 
										.rst_ni					(PRESETn),
										.wr_data					(PWDATA[7:0]),
										.ctrl_tx_buffer		(ctrl_tx_buffer),	
										.done_tx					(TXdone),
										
	// OUTPUT LOGIC CONFIGURATION		
										.ptr_addr_wr_i			(tx_fifo_wr_ptr),
										.ptr_addr_wr_o			(tx_fifo_rd_ptr),
										.wr_data_o				(tx_fifo_o)
);
//---------------------------------------------------//

endmodule
