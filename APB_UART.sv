module APB_UART																			// Wrapping APB UART OPERATING BLOCK
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input 	logic						PCLK,												// clock from CPU
	input 	logic						UARTCLK,											// this is considered as the external custom clock by user
	input 	logic						PRESETn,
	input 	logic	[  19 :   0]	desired_baud_rate,							// indicate the number of baud rate used
	input 	logic						parity_bit_mode,								// parity_bit_mode used as enable to have parity bit check if it is 1: odd or 0: even
	input 	logic						stop_bit_twice,
	//---------------------------------------------------//
	//---------------APB BRIDGE INPUT--------------------//
	input 	logic	[	 1 :   0]	fifo_en,											// enable fifo mode, fifo_en[1] for Transmit_FIFO; fifo_en[0] for Receive_FIFO
	input 	logic	[	 3 :   0]	number_data_receive, number_data_trans,// choose the number of data to receive or transfer
	input 	logic	[	 6 :   0]	ctrl_i,											// ctrl only write, only read, ..etc
	input 	logic	[	 1 :   0]	state_isr,										// interupt state of APB UART
	input 	logic 					uart_mode_clk_sel,							// sel clk for operating 0: UARTCLK, 1: PCLK
	input 	logic						PSEL,
	input 	logic 					PENABLE,
	input 	logic						PWRITE,
	input 	logic	[  11 :   0] 	PADDR,											// can increase more if # of address for other functions
	input 	logic	[   7 :   0] 	PWDATA,											// reference is 16 bit, currently use 8 bit (can custom as 16 bit, 8 MSB for function & 8 LSB for data)
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//------------------UART RETURN----------------------//
	output 	logic						PREADY,											// used by Transmitter & Receiver block
//	output 	logic						PSLVERR,											// unuse yet
	output 	reg	[  31 :   0] 	PRDATA,											// reference is 16 bit, currently use 32 bit (don't know reason why use 16 only)
	//---------------------------------------------------//
	//-----------------UART external port----------------//
   input  	logic 					UART_RXD,
	output 	logic 					UART_TXD,
	output 	logic	[   6 :   0]	UART_ERRORS,
	//---------------------------------------------------//
	
	// Delete later
	output 	logic 					baud_tick,										// intermediate register to store temporary data when passing throughout D - FF 
	output 	reg	[ 11 :   0] 	data_trans

);	

	// Local signal assignment
	
	// Logical define
	logic  [  3 :   0] 	tick_count_tx;																// signal counter to detect the state transition state of TX															// 
	logic  [  3 :   0]	ctrl_shift_register_wr;													// signal control to allow shift register to start writing
	logic	 [  3 :   0]	ctrl_shift_register_rd;													// signal control to allow shift register to start	reading
	logic						TXdone;
	logic						RXdone;																		// flag for informing when TX or RX process is done
	logic						RXen;
	logic						TXen;																			// flag for informing when RX or TX is allow to operate
	logic						error_rx_detect, error_tx_detect;									// flag for informing when RX or TX is ERROR during operation
	logic						timeout_flag; 	 															// flag for informing when time of RX is out																										// (over only when does not receied parity, stop_bit)
	logic						start_bit_tx, data_on_trans, parity_bit_tx, stop_bit_tx;		// flag for informing when start, data, parity, stop bit of TX is already sent
	logic 					data_is_avail;																// flag for informing when RX side of UART receie data
	logic						start_bit_rx, data_is_received, parity_bit_rx; 
	logic						stop_bit_rx;																// flag for informing when start, data, parity, stop bit of RX is receied
//	logic 					baud_tick;																	// signal clk when finished created as a baud rate clock for block to operate
	logic 					clk_div16;																	// signal clk raw before adding counter divisor to generate out clk for baudtick
	logic 					ctrl_tx_buffer;
	logic						ctrl_rx_buffer;															// signal for controlling FIFO of TX and RX to send out data
	logic						transfer;																	// flag for informing when transfer process is available
	logic						rx_buffer_overrun, tx_buffer_overrun;								// signal as a flag to enable FIFO to not alarm ERROR if reach its max
	logic						uart_run_flag;																// signal as an enable to allow RX or TX process to operate via apb interface
	logic 					rx_write_en;
	logic						rx_read_en;
	logic						rx_fifo_full;
	logic						rx_not_empty;
	logic						data_is_ready;
	logic						fifo_wr_ctrl;
	logic						error_ctrl;
	
	// Register define
	reg  	 [	 6 :   0]	ctrl;																			// signal for controlling the operation of UART
	reg  	 [ 12 :   0]	cd;	//(counter divisor) 												// signal for passing into BAUD_RATE_GENERATOR for counting up
	logic 	 [	 3 :   0]	state;																		// signal for informing status of UART in general
	reg 	 [	 3 :   0]	state_i;
	
	reg  	 [ 11 :   0] 	temp_rx; 																	// intermediate register to store temporary data after done receive
	reg  	 [ 11 :   0] 	temp_rx_1; 																	// intermediate register to store temporary data when passing throughout D - FF 
//	reg  	 [ 11 :   0] 	data_trans; 																// intermediate register to store temporary data when transmit into shift register
	reg 	 [  7 :   0] 	rx_fifo_mid;																// intermediate register to store temporary data before transmit out to read
	reg    [  4 :   0] 	rx_fifo_wr_ptr;															// register for RX to store value of index (pointer) for write data in
	reg 	 [  4 :   0] 	rx_fifo_rd_ptr;															// register for RX to store value of index (pointer) for read data out
	reg	 [	 7 :   0]	read_data;																	// intermediate register to store temporary data before transmit into apb interface for read out
	
	reg 	 [  4 :   0] 	tx_fifo_wr_ptr;															// register for TX to store value of index (pointer) for write data in 
	reg 	 [  4 :   0] 	tx_fifo_rd_ptr;															// register for TX to store value of index (pointer) for read data out
	reg	 [	 7 :   0]	temp_tx;																		// intermediate register to store temporary data before transmit into shift register
	reg	 [	 7 :   0]	tx_fifo_mid;																// intermediate register to store temporary data before transmit into D - FF
	reg	 [	 7 :   0]	tx_fifo_o;																	// intermediate register to store temporary data before transmit out via TXD signal
	
	assign data_is_avail = rx_not_empty;
		
	// Assignment for Errors signal happen during operation
	// Distribution: 
	// 					+) index[3:0] 	= {state_i} -> state interupt[3:2] + state report [1:0] (rx, tx fifo full)
	//						+) index[5:4] 	= {error_tx_detect, error_rx_detect}
	//						+) index[6]		= error_ctrl;
	assign UART_ERRORS = {error_ctrl, error_tx_detect, error_rx_detect, state};
	
	// Control and Status Logic
	always_ff @(posedge baud_tick or negedge PRESETn) begin
		if (!PRESETn) begin
			state_i <= 4'b0;
		end 
		else begin
			state_i[ 3 : 2] 	<= state_isr[1:0];
			if (tx_fifo_rd_ptr == 5'd31) begin
				state_i[0] 	<= 1'b1;  // if 1: full, 0 : unfull
			end
			else if (rx_fifo_wr_ptr == 5'd31) begin
				state_i[1] 	<= 1'b1;
			end
			else
				state_i[1:0] 	<= 2'b0;		
        end
    end
	
//	assign PREADY = TXdone ^ RXdone;
//---------------------------------------------------//
apb_interface						APB_INTERFACE_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.PCLK						(PCLK),
										.PRESETn					(PRESETn),
										.transfer				(transfer),
										.PENABLE					(PENABLE),
										.PWRITE					(PWRITE),
										.PWDATA					(PWDATA),
										.read_data				(read_data),
										.TXdone					(TXdone),
										.RXdone					(RXdone),
										.PADDR					(PADDR[7:0]),
										.ctrl_o					(ctrl),											// ctrl only write, only read, ..etc
										.state_isr_o			(state),
										.cd_o						(cd),
	
	//OUTPUT LOGIC ASSIGNMENT
										.uart_run_flag			(uart_run_flag),
										.PREADY					(PREADY),
										.clk_div16				(clk_div16),
										.write_data				(tx_fifo_mid),
										.PRDATA					(PRDATA)
);
//---------------------------------------------------//


//---------------------------------------------------//
ctrl_interface_signal			CTRL_INTERFACE_SIGNAL_BLOCK
(
	// INPUT LOGIC ASSIGNMENT
										.CLK						(PCLK),												// this is considered as the external custom clock by user
										.RESETn					(PRESETn),
										.PADDR					(PADDR[7:0]),
										.cfg_en					(1'b0),											// Enable config mode
										.desired_baud_rate	(desired_baud_rate),
										.ctrl_i					(ctrl_i),											// ctrl only write, only read, ..etc
										.state_isr_i			(state_i),
	
	// OUTPUT LOGIC ASSIGNMENT
										.ctrl_o					(ctrl),											// ctrl only write, only read, ..etc
										.state_isr_o			(state),
										.cd_o						(cd)
	
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
										.PCLK						(PCLK),
										.PRESETn					(PRESETn),
										.transfer				(transfer),
										.PREADY					(PREADY),
										.ctrl						(ctrl[1:0]),
										.uart_run_flag			(uart_run_flag),
										.PWRITE					(PWRITE),
	
	// OUTPUT LOGIC CONFIGURATION
										.error_ctrl				(error_ctrl),
										.TXen						(TXen),
										.RXen						(RXen)
	
);
//---------------------------------------------------//

//---------------------------------------------------//
BAUD_RATE_GENERATOR 				BAUD_RATE_GENERATOR_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.uart_ref_clk			(UARTCLK),        
										.rst_n					(PRESETn),      		
										.uart_mode_sel			(uart_mode_clk_sel),
										.baud_div_16			(clk_div16),     
										.cd						(cd),
	
	// OUTPUT LOGIC CONFIGURATION
										.baud_tick 				(baud_tick)
);
//---------------------------------------------------//

//---------------------------------------------------//
tx_fsm								TX_FSM_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick				(baud_tick),
										.PRESETn					(PRESETn),
										.stop_bit_twice		(stop_bit_twice),
										.parity_bit_mode		(parity_bit_mode),
										.TXen						(TXen),
										.PWRITE					(PWRITE),
										.start_bit				(start_bit_tx),
										.data_on_trans			(data_on_trans),
										.parity_bit				(parity_bit_tx),
										.stop_bit				(stop_bit_tx),
										.number_data_trans	(number_data_trans),
										
	// OUTPUT LOGIC CONFIGURATION
										.ctrl_shift_register	(ctrl_shift_register_wr),
										.ctrl_tx_buffer		(ctrl_tx_buffer),
										.tick_count				(tick_count_tx),
										.error_tx_detect		(error_tx_detect),
										.done_tx					(TXdone)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_8bit							DFF_TEMPORARY_STORING_WRITE
(
	// INPUT LOGIC CONFIGURATION
										.clk_i					(baud_tick), 
										.rst_ni					(PRESETn), 
										.enable					(1'b1),
										.D							(tx_fifo_o),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q							(temp_tx)
);
//---------------------------------------------------//

//---------------------------------------------------//
shift_register_wr					SHIFT_REGISTER_TX_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.parity_bit_mode		(parity_bit_mode),
										.ctrl_shift_register	(ctrl_shift_register_wr),
										.tick_count				(tick_count_tx),
										.data_in					(temp_tx),
										
	// OUTPUT LOGIC CONFIGURATION
										.start_bit				(start_bit_tx),
										.data_on_trans			(data_on_trans),
										.parity_bit				(parity_bit_tx),
										.stop_bit				(stop_bit_tx),
										.tx_out					(UART_TXD)
);
//---------------------------------------------------//

//---------------------------------------------------//
transmit_FIFO						TX_FIFO_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk_i					(baud_tick), 
										.rst_ni					(PRESETn),
										.wr_data					(tx_fifo_mid),
										.fifo_en					(fifo_en[1]),
										.ctrl_tx_buffer		(ctrl_tx_buffer),	
										.done_tx					(TXdone),
										.TXen						(TXen),
										.tx_buffer_overrun	(tx_buffer_overrun),
										.rx_state_full			(state_i[0]),
										
	// OUTPUT LOGIC CONFIGURATION		
										.ptr_addr_wr_i			(tx_fifo_wr_ptr),
										.ptr_addr_wr_o			(tx_fifo_rd_ptr),
										.wr_data_o				(tx_fifo_o)
);
//---------------------------------------------------//

//---------------------------------------------------//
uart_start_bit_detect 			UART_START_BIT_DETECT_BLOCK
(	
	// INPUT LOGIC CONFIGURATION
	
										.clk_i					(baud_tick),
										.rst_ni					(PRESETn),
										.UART_RXD				(UART_RXD),
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.number_data_receive	(number_data_receive),
										.RXen						(RXen),
										.cd						(cd),
										.uart_mode_clk_sel	(uart_mode_clk_sel),
	
	// OUTPUT LOGIC CONFIGURATION	
										.fifo_wr_ctrl			(fifo_wr_ctrl),
										.data_out				(data_trans)
);
//---------------------------------------------------//

//---------------------------------------------------//
receive_FIFO						RECEIVE_FIFO_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk						(baud_tick),
										.rst_n					(PRESETn),
										.fiford					(ctrl_rx_buffer),
										.fifowr					(fifo_wr_ctrl),
										.RXdone					(RXdone),
										
	// OUTPUT LOGIC CONFIGURATION
										.fifofull				(rx_fifo_full),
										.notempty				(rx_not_empty),
										.write					(rx_write_en),
										.read						(rx_read_en),
										.rx_ptr_addr_wr_i		(rx_fifo_wr_ptr),
										.rx_ptr_addr_rd_o		(rx_fifo_rd_ptr),
										.data_is_ready			(data_is_ready)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_12bit							D_FLIPFLOP_12BITS_FOR_TEMP_STORE
(	
	// INPUT LOGIC CONFIGURATION
										.rst_ni					(PRESETn),
										.baud_tick				(baud_tick),
										.enable					(ctrl_rx_buffer), 	
										.D							(temp_rx_1),
	
	//OUTPUT LOGIC ASSIGNMENT
										.Q							(temp_rx)
); 
//---------------------------------------------------//

//---------------------------------------------------//
fifo_read_memory					FIFO_READ_MEMORY_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk						(PCLK),
										.rst_n					(PRESETn),
										.write_en				(rx_write_en),
										.read_en					(rx_read_en),
										.write_data				(data_trans),
										.wraddr					(rx_fifo_wr_ptr),
										.rdaddr					(rx_fifo_rd_ptr),
										.fifofull				(rx_fifo_full),
										.notempty				(rx_not_empty),
										.fifo_en					(fifo_en[0]),
										
	// OUTPUT LOGIC CONFIGURATION
										.read_data				(temp_rx_1)
);
//---------------------------------------------------//

//---------------------------------------------------//
rx_fsm								RX_FSM_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.baud_tick				(baud_tick),
										.PRESETn					(PRESETn),
										.parity_bit_mode		(parity_bit_mode),
										.stop_bit_twice		(stop_bit_twice),
										.data_is_avail			(notempty),
										.data_is_ready			(data_is_ready),
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
										.data_in					(temp_rx),
										
	// OUTPUT LOGIC CONFIGURATION
										.start_bit				(start_bit_rx),
										.data_is_received		(data_is_received),
										.parity_bit				(parity_bit_rx),
										.stop_bit				(stop_bit_rx),
										.rx_out					(rx_fifo_mid)
);
//---------------------------------------------------//

//---------------------------------------------------//
D_FF_8bit							DFF_TEMPORARY_STORING_READ
(
	// INPUT LOGIC CONFIGURATION
										.clk_i					(PCLK), 
										.rst_ni					(PRESETn), 
										.enable					(1'b1),
										.D							(rx_fifo_mid),
	
	// OUTPUT LOGIC CONFIGURATION
										.Q							(read_data)
);
    

endmodule