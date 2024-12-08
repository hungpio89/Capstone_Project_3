module receive_FIFO
(
	// INPUT LOGIC CONFIGURATION
	
	//-------------------CPU INPUT-----------------------//
	input		logic					clk, 							//clock 
	input		logic					rst_n,
	//---------------------------------------------------//
	
	//--------------FIFO CONTROL SIGNAL------------------//
	input		logic 				fiford,    					// FIFO control
	input		logic 				fifowr,
	input		logic					RXdone,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//-----------------CONTROL OUTPUT--------------------//
	output	logic 				fifofull,  					// high when fifo full
	output	logic 				notempty,  					// high when fifo not empty
	//---------------------------------------------------//
	
	//----------------CONNECT TO MEMORIES----------------//
	output	logic					write,    					// write address of memories
	output	logic					read,      					// enable to read memories=
	output 	logic	[  4:  0]	rx_ptr_addr_wr_i,
	output 	logic	[  4:  0]	rx_ptr_addr_rd_o,			// read address of memories
	output	logic					data_is_ready
	//---------------------------------------------------//
);

	// Local no-need appear assignment 
	
	// Local register signal define
	reg	[  5:  0]   		fifo_len;
	reg	[  5:  0]   		fifo_rd;	
	reg	[  4:  0] 			wrcnt;
	reg	[  4:  0]			rdcnt;	

	// Local logic signal define
	logic							fifoempt;
	logic							fifo_read_en;
	logic	[  5:  0]			fifolen;
	
	// Locally assignment
	assign  rx_ptr_addr_wr_i	= 	wrcnt;
	assign  fifoempt    			=	(fifo_len==6'b0);
	assign  notempty    			=	!fifoempt;
	assign  fifofull    			=	(fifo_len[5]);
	assign  write       			=	(fifowr& !fifofull);
	assign  read        			=	(fiford& !fifoempt);
	assign  rx_ptr_addr_rd_o	= 	rdcnt;
	
	// Always loop for control output signal
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			wrcnt 	 <= 5'b0;				// restart to zero
			fifo_len  <= 6'b0;
		end
		else begin
			if(write) begin
				wrcnt     <= wrcnt  + 1'b1;
				fifo_len  <= fifo_len + 1'b1;
			end
		end
	end

compare_5bit 				COMPARE_5BITS_BLOCK
(
	// INPUT LOGIC CONFIGURATION
										.A						(rx_ptr_addr_rd_o),
										.B						(fifolen),

	// OUTPUT LOGIC CONFIGURATION
										.A_less_B			(fifo_read_en)
);

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			rdcnt		 <= 5'b0;				// restart to zero
			fifo_rd   <= 6'b0;
		end
		else begin 
			if (RXdone) begin
				rdcnt				<= rdcnt + 1'b1;
				fifo_rd  		<= fifo_rd + 1'b1;
			end
			else
				rdcnt		 		<= rdcnt;
				fifo_rd   		<= fifo_rd;
		end
	end
	
	assign fifolen = fifo_len;
	assign data_is_ready = (read && fifo_read_en);

endmodule
