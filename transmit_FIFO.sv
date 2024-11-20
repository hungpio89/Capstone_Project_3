module transmit_FIFO													// operating as FIFO
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input  logic				  	clk_i, 
	input  logic    			  	rst_ni,			
	//---------------------------------------------------//
	//----------------APB INTERFACE INPUT----------------//
	input  logic [  7 :  0]    wr_data,                 	// the write data ready for shift
	input  logic					fifo_en,
	//---------------------------------------------------//
	//-------------------TX FSM INPUT--------------------//
	input  logic				  	ctrl_tx_buffer,				// indicate the singal feedback from tx_fsm for next shifting
	input  logic 				  	done_tx,
	input  logic					TXen,
	input  logic					tx_buffer_overrun,			// flag for setting mode UART TX (unused yet)
	input  logic					rx_state_full,					// flag indicate the buffer (FIFO) is fullfill
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//----------------APB INTERFACE INPUT----------------//
	output reg   [ 4 :  0] 	  ptr_addr_wr_i,
	output reg   [ 4 :  0] 	  ptr_addr_wr_o,
	output reg   [ 7 :  0]    wr_data_o							// read data out for shift process
	//---------------------------------------------------//
);

	reg 	[ 7 :  0] mem 			[0 : 31];  

	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			ptr_addr_wr_o <= 5'b0;
		end
		else begin
			if (fifo_en && TXen) begin
				// read out buffer operation
				if (ctrl_tx_buffer) begin
					ptr_addr_wr_o <= ptr_addr_wr_o + 5'd1; 
				end
			end
			else
				ptr_addr_wr_o <= ptr_addr_wr_o;
		end
	end
	
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			wr_data_o		<= 8'b0;
		end
		else begin
			// read out buffer operation
			if (fifo_en && TXen) begin
				if (ctrl_tx_buffer) begin
					wr_data_o 			 <= mem[ptr_addr_wr_o]; 
				end
				else
					wr_data_o 			 <= wr_data_o;
			end
			else
				wr_data_o				 <= wr_data;
		end
	end

	// write into buffer operation
	always_ff @(posedge clk_i, negedge rst_ni) begin
	// If reset signal is active, reset all registers
		if (!rst_ni) begin           
			for (integer j = 0; j < 32; j = j + 1) begin
				mem[j] 		<= 8'b0;
			end
			ptr_addr_wr_i 	<= 5'b0;
		end
		else begin
			if (TXen) begin
				// Write the data into buffer 
				if (fifo_en) begin
					if (rx_state_full) begin						// clear FIFO
						for (integer j = 0; j < 32; j = j + 1) begin: reset_FIFO
							mem[j] 		<= 8'b0;
						end
						ptr_addr_wr_i 			<= 5'd0;
					end
					if (ptr_addr_wr_i == 5'd0) begin				// checking condition of PTR in case first write or others
						mem [ptr_addr_wr_i]  <= wr_data;
						ptr_addr_wr_i 			<= ptr_addr_wr_i + 5'd1;
					end
					else begin
//						if (mem [ptr_addr_wr_i - 5'd1] != wr_data) begin 									
							mem [ptr_addr_wr_i]  <= wr_data;
							ptr_addr_wr_i 			<= ptr_addr_wr_i + 5'd1;
//						end
//						else
//							ptr_addr_wr_i 			<= ptr_addr_wr_i;
					end
				end
			end
		end
	end
	

endmodule
