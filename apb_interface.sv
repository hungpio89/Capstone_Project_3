module apb_interface										// & register block 
(
	// INPUT LOGIC CONFIGURATION
	//------------------CPU INPUT------------------------//
	input 	logic						PCLK,
	input 	logic						PRESETn,
	//---------------------------------------------------//
	
	//-----------------APB INTERFACE---------------------//
	input 	logic						transfer,			// correct address index or not (PSEL & PADDR[11:8])
	input 	logic 					PENABLE,
	input 	logic						PWRITE,
	input 	reg  	 [   7 :   0] 	PADDR,
	input 	reg  	 [   7 :   0] 	PWDATA,				// reference is 16 bit, currently use 8 bit (know reason why use 16 -> CONFIGURATION OF UART 8 bits or 16 bits send each)
	
	//---------------------------------------------------//
	
	//------------------UART RETURN----------------------//
	input 	reg	 [	  7 :   0]	read_data,
	//---------------------------------------------------//
	
	//-------------------USER INPUT----------------------//
	
	input 	logic 					TXdone, 
	input 	logic 					RXdone,
	input 	logic	[	 6 :   0]	ctrl_o,											// ctrl only write, only read, ..etc
	input 	logic	[	 3 :   0]	state_isr_o,
	input 	logic	[  12 :   0]	cd_o,
	
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	//--------------APB INTERFACE RETURN-----------------//
	output 	logic 					rx_buffer_overrun, 
	output 	logic 					tx_buffer_overrun,
	output 	logic 					uart_run_flag,		// to control the TX and RX operation (only active in case transmit or receive data)
	output 	logic						PREADY,				// used by Transmitter & Receiver block
	output 	logic 					clk_div16,
	output 	reg 	 [   7 :   0] 	write_data,			// reference is 16 bit, currently use 8 bits
	
	output 	reg	 [  31 :   0] 	PRDATA
	//---------------------------------------------------//
);
	// Local signal define
	
	// Logic
	logic								uart_run_flag_wr, uart_run_flag_rd;
	logic 		[   7 :   0] 	uart_data_mid;
	logic			[	 1 :	 0]	ctrl_signal;
	logic								PREADY_temp, PREADY_mid;
	
	// Register
	reg			[   7 :   0] 	base_offset; 
	reg			[  31 :   0] 	PRDATA_temp;
	
	// Local signal assignment for PADDR
	genvar i;
	generate 
		for (i = 0; i < 8; i = i + 1) begin: offset_assignment
			assign base_offset[i] = PADDR[i];
		end
	endgenerate
	
	// Local signal assigment for control apb interface
	assign ctrl_signal = {transfer, PENABLE}; 
	
baud_rate_divisor 				BAUD_RATE_DIVISOR_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.clk					(PCLK),
										.rst_n				(PRESETn),
	 
	// OUTPUT LOGIC CONFIGURATION
										.clk_out				(clk_div16)
);

or_1bit								OR_GATE_BLOCK_1
(
	// INPUT LOGIC CONFIGURATION
										.data_in1			(RXdone),
										.data_in2			(TXdone),
	
	// OUTPUT LOGIC CONFIGURATION
										.data_out			(PREADY)
);
	
or_1bit								OR_GATE_BLOCK_2
(
	// INPUT LOGIC CONFIGURATION
										.data_in1			(PREADY_temp),
										.data_in2			(TXdone),
	
	// OUTPUT LOGIC CONFIGURATION
										.data_out			(PREADY_mid)
);

or_1bit								OR_GATE_BLOCK_3
(
	// INPUT LOGIC CONFIGURATION
										.data_in1			(uart_run_flag_wr),
										.data_in2			(uart_run_flag_rd),
	
	// OUTPUT LOGIC CONFIGURATION
										.data_out			(uart_run_flag)
);
	
	// APB Interface
	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin										// RESETn operation (reset all registers)
			uart_data_mid 	= 8'b0;
			uart_run_flag_wr  = 1'b0;
		end 
		else begin
			case (ctrl_signal)
				2'b11: begin
					if (PWRITE) begin										// WRITING MODE
						uart_run_flag_wr  = 1'b1;
						uart_data_mid 	= PWDATA[  7 :  0];
					end
				end
				default: begin
					uart_run_flag_wr  = 1'b0;
				end
			endcase
		end
	end
	
	always @(posedge PCLK or negedge PRESETn) begin
		if (!PRESETn) begin				
			uart_run_flag_rd  = 1'b0;
			PREADY_temp			= 1'b0;
		end 
		else begin
			PRDATA_temp	= PRDATA_temp;
			PREADY_temp	= PREADY_temp;
			case (ctrl_signal)
				2'b11: begin
					if (!PWRITE) begin												// READING MODE
						case(base_offset)
							8'h0: begin 									// read state
								PRDATA_temp 		= {28'b0, state_isr_o};	
								PREADY_temp			= 1'b1;
							end
							8'h4: begin 									// read ctrl 
								PRDATA_temp			= {25'b0, ctrl_o};
								PREADY_temp			= 1'b1;
							end	
							8'h8: begin										// read cd
								PRDATA_temp			= {19'b0, cd_o};
								PREADY_temp			= 1'b1;
							end
							default: begin									// read data
								uart_run_flag_rd	= 1'b1;
								PRDATA_temp 		= {24'b0, read_data};
								PREADY_temp	  		= 1'b1;
							end
						endcase
					end
				end
				default: begin
					PRDATA_temp			= PRDATA_temp;
					uart_run_flag_rd  = 1'b0;
					PREADY_temp			= 1'b0;
				end
			endcase
		end
	end
	
	// Local signal assignment for write_data
	genvar k;
	generate 
		for (k = 0; k < 8; k = k + 1) begin: data_write_assignment
			assign write_data[k] = uart_data_mid[k];
		end
	endgenerate
	
	// Local signal assignment for write_data
	genvar l;
	generate 
		for (l = 0; l < 32; l = l + 1) begin: data_read_assignment
			assign PRDATA[l] = PRDATA_temp[l];
		end
	endgenerate

endmodule
