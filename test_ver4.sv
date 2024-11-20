module test_ver4												// Wrapping APB UART OPERATING BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic						UARTCLK,					// this is considered as the external custom clock by user
	input logic						PRESETn,
	//---------------------------------------------------//
	//---------------APB BRIDGE INPUT--------------------//
	input logic	 [	 3 :   0]	number_data_receive,
	input logic	 					parity_bit_mode,
	input logic						stop_bit_twice,
	input logic						PWRITE, PENABLE, PSEL,
	input logic	 [ 11 :   0]	PADDR,
	input logic  [  7 :   0] 	PWDATA,  
	input logic  [ 19 :   0]	desired_baud_rate,
	output logic [ 31 :   0]	PRDATA,
	input logic	 [  6 :   0]  	ctrl_i,
	input logic						fifo_en,
	input logic 					UART_RXD,
	input logic  [  3 :   0]	state_i,
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//---------------------------------------------------//
	//---------------------------------------------------//
	
	// For simulation only (delete later) -> if not use move to local assignment signal
	output logic					error_rx_detect, error_tx_detect, done_flag, data_is_avail,
	output logic					TXen, RXen, TXdone, RXdone, timeout_flag,
	output logic [  3 :   0]	ctrl_shift_register_rd,								// data_avail, 
	output logic					start_bit_rx, data_is_received, parity_bit_rx, stop_bit_rx,
	output logic 					clk_div16, ctrl_rx_buffer, PREADY,
	output logic [ 12 :   0]	cd,				// counter div
	output logic [	 3 :   0]	state,
	output logic [	 7 :   0]	read_data,
	output logic					transfer, uart_run_flag,
	output logic [  7 :   0] 	rx_fifo_mid, tx_fifo_mid,
	output logic [  4 :   0] 	rx_fifo_wr_ptr,
	output logic [  4 :   0] 	rx_fifo_rd_ptr,
	output logic [	 6 :   0]	ctrl,
	output logic [ 11 :   0]	temp_rx, temp_rx_1, temp_rx_2
	//---------------------------------------------------//
);	

		logic 	[  3 :  0]		j;

//---------------------------------------------------//
apb_interface						APB_INTERFACE_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PCLK						(UARTCLK),
										.PRESETn					(PRESETn),
										.transfer				(transfer),
										.PENABLE					(PENABLE),
										.PWRITE					(PWRITE),
										.PADDR					(PADDR[7:0]),
										.PWDATA					(PWDATA),
										.state_i					(state_i),
										.ctrl_i					(ctrl_i),
										.read_data				(read_data),
										.desired_baud_rate	(desired_baud_rate),
										.TXdone					(TXdone),
										.RXdone					(RXdone),
										.error_tx_detect		(error_tx_detect),
										.error_rx_detect		(error_rx_detect),
	
	//OUTPUT LOGIC ASSIGNMENT
										.uart_run_flag			(uart_run_flag),
										.PREADY					(PREADY),				
										.cd						(cd),
										.clk_div16				(clk_div16),
										.state					(state),						// noted for future use (checking whether the currently state can insert data or not)		
										.ctrl						(ctrl),
										.write_data				(tx_fifo_mid),
										.PRDATA					(PRDATA)
);

//---------------------------------------------------//
// block for checking whether the transfer is valid or not
transfer_validate 				TRANSFER_VALID_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
										.PSEL						(PSEL),
										.PADDR					(PADDR[11:8]),
	 
	// OUTPUT LOGIC ASSIGNMENT
										.transfer				(transfer)
);
//---------------------------------------------------//

//---------------------------------------------------//
custom_fsm_wr_rd					CUSTOM_FSM_WR_RD_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PCLK						(UARTCLK),
										.PRESETn					(PRESETn),
										.transfer				(transfer),
										.PREADY					(PREADY),
										.ctrl						(ctrl[1:0]),
										.uart_run_flag			(uart_run_flag),
										.PWRITE					(PWRITE),
	
	// OUTPUT LOGIC CONFIGURATION
										.TXen						(TXen),
										.RXen						(RXen)
	
);
//---------------------------------------------------//
//---------------------------------------------------//
uart_start_bit_detect 			UART_START_BIT_DETECT_BLOCK
(	
	// INPUT LOGIC CONFIGURATION
	
										.clk_i					(UARTCLK),
										.rst_ni					(PRESETn),
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.UART_RXD				(UART_RXD),
										.number_data_receive	(number_data_receive),
										.RXen						(RXen),
	
	// OUTPUT LOGIC CONFIGURATION	
										.done_flag				(done_flag),
										.data_out				(temp_rx)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_12bit							DFF_TEMPORARY_STORING_RECEIVING
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick				(UARTCLK), 
										.rst_ni					(PRESETn), 
										.enable					(done_flag),
										.D							(temp_rx),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q							(temp_rx_1)
);	
//---------------------------------------------------//

//---------------------------------------------------//
receive_FIFO						RX_FIFO_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk_i					(UARTCLK), 
										.rst_ni					(PRESETn),
										.rd_data_i				(temp_rx_1),
										.ctrl_rx_buffer		(ctrl_rx_buffer),	
										.RXen						(RXen),
										.done_flag				(done_flag),
										.fifo_en					(fifo_en),
										
	// OUTPUT LOGIC CONFIGURATION		
										.data_is_avail			(data_is_avail),
										.rx_ptr_addr_wr_i		(rx_fifo_wr_ptr),
										.rx_ptr_addr_rd_o		(rx_fifo_rd_ptr),
										.rx_data_o				(temp_rx_2)
);
//---------------------------------------------------//

//---------------------------------------------------//
rx_fsm								RX_FSM_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick				(UARTCLK),
										.PRESETn					(PRESETn),
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.data_is_avail			(data_is_avail),
										.RXen						(RXen),
										.PWRITE					(PWRITE),
										.start_bit				(start_bit_rx),
										.data_is_received		(data_is_received),
										.parity_bit				(parity_bit_rx),
										.stop_bit				(stop_bit_rx),
										.number_data_receive	(number_data_receive),
										
	// OUTPUT LOGIC CONFIGURATION
										.ctrl_shift_register	(ctrl_shift_register_rd),
										.ctrl_rx_buffer		(ctrl_rx_buffer),
										.error_rx_detect		(error_rx_detect),
										.timeout_flag			(timeout_flag),
										.rx_done					(RXdone)
);
//---------------------------------------------------//

//---------------------------------------------------//
shift_register_rd					SHIFT_REGISTER_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.number_data_receive	(number_data_receive),
										.ctrl_shift_register	(ctrl_shift_register_rd),
										.data_in					(temp_rx_2),
										
	// OUTPUT LOGIC CONFIGURATION
										.start_bit				(start_bit_rx),
										.data_is_received		(data_is_received),
										.parity_bit				(parity_bit_rx),
										.stop_bit				(stop_bit_rx),
										.rx_out					(rx_fifo_mid)
);
//---------------------------------------------------//

////---------------------------------------------------//
D_FF_8bit							DFF_TEMPORARY_STORING_READ
(
	// INPUT LOGIC CONFIGURATION
										.clk_i					(UARTCLK), 
										.rst_ni					(PRESETn), 
										.enable					(RXdone),
										.D							(rx_fifo_mid),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q							(read_data)
);
//---------------------------------------------------//

endmodule