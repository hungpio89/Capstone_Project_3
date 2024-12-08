module test_ver5
(
	// INPUT LOGIC CONFIGURATION
	
	//-------------------CPU INPUT------------------------//
	input		logic					PCLK, 
	input 	logic					UARTCLK,											// this is considered as the external custom clock by user
	input 	logic					PRESETn,
	//---------------------------------------------------//
	
	//------------------CPU INPUT------------------------//
	input 	logic	[  19 :   0]	desired_baud_rate,							// indicate the number of baud rate used
	//---------------------------------------------------//
	
	//----------UART START BIT DETECT INPUT--------------//
	input		logic					UART_RXD,    					// UART RX input
	input		logic					parity_bit_mode,
	input		logic					stop_bit_twice,
	input 	logic					uart_mode_clk_sel,
	//---------------------------------------------------//
	
	//---------------APB BRIDGE INPUT--------------------//
	input 	logic	[	 3:   0]	number_data_receive,							// choose the number of data to receive or transfer
	input 	logic	[	 6:   0]	ctrl_i,											// ctrl only write, only read, ..etc
	input 	logic	[	 1:   0]	state_isr,										// interupt state of APB UART
	input 	logic					PSEL,
	input 	logic 				PENABLE,
	input 	logic					PWRITE,
	input 	logic	[  11:   0] PADDR,											// can increase more if # of address for other functions
		//---------------------------------------------------//
	
	output 	logic	[  12:   0]	cd,
	output 	logic [	 6:   0]	ctrl,
	
	// OUTPUT LOGIC CONFIGURATION
	
	//-----------------CONTROL OUTPUT--------------------//
	output	logic					RXen, transfer, uart_run_flag,
	output 	logic 				baud_tick,
	output	logic	[  11:   0] temp_rx_1,    				// 12-bit output signal
	output	logic 				rx_fifo_full,  					// high when fifo full
	output	logic 				rx_not_empty,  			// high when fifo not empty
	output	logic					rx_write_en,    					// write address of memories
	output	logic					rx_read_en,      					// enable to read memories
	output	logic					data_is_ready,
	output	logic	[   4:   0]	rx_ptr_addr_wr_i,
	output	logic	[   4:   0]	rx_ptr_addr_rd_o,			// read address of memories
	output	logic	[  11:   0] temp_rx,
	output   logic [	 7:   0]	read_data,
	output 	reg	[  11:   0]	data_trans, 
	output 	reg	[   7:   0] rx_fifo_mid,
	output 	logic					ctrl_rx_buffer,
	output 	logic					fifo_wr_ctrl,
	output 	logic					data_is_avail,																// flag for informing when RX side of UART receie data
	output 	logic					RXdone, start_bit_rx, data_is_received, parity_bit_rx, stop_bit_rx, error_rx_detect, timeout_flag, TXdone, 
	output 	logic	[   3:   0]	ctrl_shift_register_rd,	
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//------------------UART RETURN----------------------//
	output logic					PREADY,
	output logic 	[  31:   0] PRDATA
);
	
//	logic 					uart_run_flag;
	
	
	assign data_is_avail = rx_not_empty;
	assign PREADY			= RXdone;
//---------------------------------------------------//
apb_interface						APB_INTERFACE_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PCLK							(PCLK),
										.PRESETn						(PRESETn),
										.transfer					(transfer),
										.PENABLE						(PENABLE),
										.PWRITE						(PWRITE),
										.PWDATA						(PWDATA),
										.read_data					(read_data),
										.TXdone						(TXdone),
										.RXdone						(RXdone),
										.error_tx_detect			(error_tx_detect),
										.error_rx_detect			(error_rx_detect),
	
	//OUTPUT LOGIC ASSIGNMENT
										.uart_run_flag				(uart_run_flag),
										.PREADY						(),
										.clk_div16					(clk_div16),
										.write_data					(),
										.PRDATA						(PRDATA)
);
//---------------------------------------------------//

//---------------------------------------------------//
ctrl_interface_signal			CTRL_INTERFACE_SIGNAL_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
										.CLK							(PCLK),												// this is considered as the external custom clock by user
										.RESETn						(PRESETn),
										.PADDR						(PADDR),
										.cfg_en						(1'b0),											// Enable config mode
										.desired_baud_rate		(desired_baud_rate),
										.ctrl_i						(ctrl_i),											// ctrl only write, only read, ..etc
										.state_isr_i				(state_i),
	
	// OUTPUT LOGIC ASSIGNMENT
										.ctrl_o						(ctrl),											// ctrl only write, only read, ..etc
										.state_isr_o				(state),
										.cd_o							(cd)
	
);
//---------------------------------------------------//

//---------------------------------------------------//
// block for checking whether the transfer is valid or not
transfer_validate 				TRANSFER_VALID_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
										.PSEL							(PSEL),
										.PADDR						(PADDR[11:8]),
	 
	// OUTPUT LOGIC ASSIGNMENT
										.transfer					(transfer)
);
//---------------------------------------------------//

//---------------------------------------------------//
custom_fsm_wr_rd					CUSTOM_FSM_WR_RD_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PCLK							(PCLK),
										.PRESETn						(PRESETn),
										.transfer					(transfer),
										.PREADY						(PREADY),
										.ctrl							(ctrl[1:0]),
										.uart_run_flag				(uart_run_flag),
										.PWRITE						(PWRITE),
	
	// OUTPUT LOGIC CONFIGURATION
										.TXen							(),
										.RXen							(RXen)
	
);
//---------------------------------------------------//
	
//---------------------------------------------------//
BAUD_RATE_GENERATOR 				BAUD_RATE_GENERATOR_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.uart_ref_clk				(UARTCLK),        
										.rst_n						(PRESETn),      		
										.uart_mode_sel				(uart_mode_clk_sel),
										.baud_div_16				(clk_div16),     
										.cd							(cd),
	
	// OUTPUT LOGIC CONFIGURATION
										.baud_tick 					(baud_tick)
);
//---------------------------------------------------//
	
uart_start_bit_detect			UART_DETECT_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk_i						(baud_tick),
										.rst_ni						(PRESETn),
										.UART_RXD					(UART_RXD),
										.parity_bit_mode			(parity_bit_mode),
										.stop_bit_twice			(stop_bit_twice),
										.number_data_receive		(number_data_receive),
										.RXen							(RXen),
										.cd							(cd),
										.uart_mode_clk_sel		(uart_mode_clk_sel),
	
	// OUTPUT LOGIC CONFIGURATION
										.fifo_wr_ctrl				(fifo_wr_ctrl),
										.data_out					(data_trans)
);
//---------------------------------------------------//

receive_FIFO						RECEIVE_FIFO_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk							(baud_tick),
										.rst_n						(PRESETn),
										.fiford						(ctrl_rx_buffer),
										.fifowr						(fifo_wr_ctrl),
										.RXdone						(RXdone),
	
	// OUTPUT LOGIC CONFIGURATION
										.fifofull					(rx_fifo_full),
										.notempty					(rx_not_empty),
										.write						(rx_write_en),
										.read							(rx_read_en),
										.rx_ptr_addr_wr_i			(rx_ptr_addr_wr_i),
										.rx_ptr_addr_rd_o			(rx_ptr_addr_rd_o),
										.data_is_ready				(data_is_ready)
);

//---------------------------------------------------//
D_FF_12bit							D_FLIPFLOP_12BITS_FOR_TEMP_STORE
(	
	// INPUT LOGIC CONFIGURATION
										.rst_ni						(PRESETn),
										.baud_tick					(baud_tick),
										.enable						(ctrl_rx_buffer), 	
										.D								(temp_rx_1),
	
	//OUTPUT LOGIC ASSIGNMENT
										.Q								(temp_rx)
); 

//---------------------------------------------------//
fifo_read_memory 					FIFO_BLOCK_MEMORY
(
										.clk							(PCLK),         				// Clock signal
										.rst_n						(PRESETn),       				// Active-low reset
										.write_en					(rx_write_en),    					// Write enable (push data)
										.read_en						(rx_read_en),     					// Read enable (pop data)
										.write_data					(data_trans),  				// Data to write into the FIFO
										.wraddr						(rx_ptr_addr_wr_i),  		// Address to write into the FIFO
										.rdaddr						(rx_ptr_addr_rd_o),  	 	// Address to read from the FIFO
										.fifofull					(rx_fifo_full),      		// High when FIFO is fifofull
										.notempty					(rx_not_empty),				// High when FIFO is empty
										.fifo_en						(1'b1),
	
										.read_data					(temp_rx_1)   					// Data read from the FIFO
);


//---------------------------------------------------//
rx_fsm								RX_FSM_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick					(baud_tick),
										.PRESETn						(PRESETn),
										.parity_bit_mode			(parity_bit_mode),
										.stop_bit_twice			(stop_bit_twice),
										.data_is_avail				(rx_not_empty),
										.data_is_ready				(data_is_ready),
										.RXen							(RXen),
										.PWRITE						(PWRITE),
										.start_bit					(start_bit_rx),
										.data_is_received			(data_is_received),
										.parity_bit					(parity_bit_rx),
										.stop_bit					(stop_bit_rx),
										.number_data_receive		(number_data_receive),
										
	// OUTPUT LOGIC CONFIGURATION
										.ctrl_shift_register		(ctrl_shift_register_rd),
										.ctrl_rx_buffer			(ctrl_rx_buffer),
										.error_rx_detect			(error_rx_detect),
										.timeout_flag				(timeout_flag),
										.rx_done						(RXdone)
);
//---------------------------------------------------//


//---------------------------------------------------//
shift_register_rd					SHIFT_REGISTER_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.parity_bit_mode			(parity_bit_mode),
										.stop_bit_twice			(stop_bit_twice),
										.number_data_receive		(number_data_receive),
										.ctrl_shift_register		(ctrl_shift_register_rd),
										.data_in						(temp_rx),
										
	// OUTPUT LOGIC CONFIGURATION
										.start_bit					(start_bit_rx),
										.data_is_received			(data_is_received),
										.parity_bit					(parity_bit_rx),
										.stop_bit					(stop_bit_rx),
										.rx_out						(rx_fifo_mid)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_8bit							DFF_TEMPORARY_STORING_READ
(
	// INPUT LOGIC CONFIGURATION
										.clk_i						(PCLK), 
										.rst_ni						(PRESETn), 
										.enable						(1'b1),
										.D								(rx_fifo_mid),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q								(read_data)
);

endmodule
