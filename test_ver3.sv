module test_ver3												// Wrapping APB UART OPERATING BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic						UARTCLK,					// this is considered as the external custom clock by user
	input logic						PRESETn,
	//---------------------------------------------------//
	//---------------APB BRIDGE INPUT--------------------//
	input logic						PWRITE, PENABLE, PSEL,
	input logic	 [ 11 :   0]	PADDR,
	input logic  [  7 :   0] 	PWDATA, read_data, 
	input logic  [ 19 :   0]	desired_baud_rate,
	input logic  [  3 :   0]	state_i, 
	input logic						TXdone, RXdone,
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//---------------------------------------------------//
	//---------------------------------------------------//
	
	// For simulation only (delete later) -> if not use move to local assignment signal
	output logic [  31 :   0]	PRDATA,
	output logic [   1 :   0]	ctrl,
	output logic [  12 :   0]	cd,
	output logic 	 				PREADY, uart_run_flag,
	output logic [   3 :   0]  state,
	output logic [   7 :   0]  tx_fifo_mid,
	output logic					transfer, clk_div16, RXen, TXen
	//---------------------------------------------------//
);	

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
										.read_data				(read_data),
										.desired_baud_rate	(desired_baud_rate),
										.TXdone					(TXdone),
										.RXdone					(RXdone),
										.uart_run_flag			(uart_run_flag),
	
	//OUTPUT LOGIC ASSIGNMENT
										.PREADY					(PREADY),				
										.cd						(cd),
										.clk_div16				(clk_div16),
										.state					(state),						// noted for future use (checking whether the currently state can insert data or not)		
										.ctrl						(ctrl),
										.write_data				(tx_fifo_mid),
										.PRDATA					(PRDATA)
);
//---------------------------------------------------//

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
										.ctrl						(ctrl),
										.uart_run_flag			(uart_run_flag),
	
	// OUTPUT LOGIC CONFIGURATION
										.TXen						(TXen),
										.RXen						(RXen)
	
);
//---------------------------------------------------//

endmodule