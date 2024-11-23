module receive_FIFO
(
	input		logic				clkw, 						//clock write
	input		logic				clkr, 						//clock read
	input		logic				rst_n,
     
	input		logic 			fiford,    					// FIFO control
	input		logic 			fifowr,

	output	logic 			fifofull,  					// high when fifo full
	output	logic 			notempty,  					// high when fifo not empty

	// Connect to memories
	output					 	write,    					// write address of memories
	output 						read,      					// enable to read memories
	
	output [  4:  0] 			rx_ptr_addr_wr_i,
	output [  4:  0] 			rx_ptr_addr_rd_o						// read address of memories
);

	reg	[  5:  0]   		fifo_len;
	reg	[  5:  0]   		fifo_rd;	
	reg	[  4:  0] 			wrcnt;
	reg	[  4:  0]			rdcnt;	
	
	wire							fifoempt;
	
	assign  rx_ptr_addr_wr_i	= 	wrcnt;
	assign  fifoempt    			=	(fifo_len==6'b0);
	assign  notempty    			=	!fifoempt;
	assign  fifofull    			=	(fifo_len[5]);
	assign  write       			=	(fifowr& !fifofull);
	assign  read        			=	(fiford& !fifoempt);
	assign  rx_ptr_addr_wr_i	= 	rdcnt;

	always @(posedge clkw or negedge rst_n) begin
		if(!rst_n) begin
			wrcnt 	 <= 5'b0;				// restart to zero
			fifo_len  <= 6'b0;
		end
		else begin
			if(write) begin
				wrcnt     <= wrcnt  + 1'b1;
				fifo_len  <= fifo_len + 1'b1;
			end
			else
				wrcnt     <= wrcnt;
				fifo_len  <= fifo_len;
		end
	end

	always @(posedge clkr or negedge rst_n) begin
		if(!rst_n) begin
			rdcnt		 <= 5'b0;				// restart to zero
			fifo_rd   <= 6'b0;
		end
		else if (read) begin
			if (fifo_rd <= fifo_len) begin
				rdcnt		<= rdcnt + 1'b1;
				fifo_rd  <= fifo_rd + 1'b1;
			end
			else
				rdcnt		 <= 5'b0;			// restart to zero
				fifo_rd   <= 6'b0;
		end	
	end

endmodule
