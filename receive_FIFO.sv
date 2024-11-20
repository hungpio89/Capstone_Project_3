module receive_FIFO													// operating as FIFO
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input  logic				  	clk_i, 
	input  logic    			  	rst_ni,			
	//---------------------------------------------------//
	//----------------APB INTERFACE INPUT----------------//
	input  logic [ 11 :  0]    rd_data_i,                 // the write data ready for shift
	input  logic					fifo_en,							// indicate FIFO is used or not
	//---------------------------------------------------//
	//-------------------RX FSM INPUT--------------------//
	input  logic				  	ctrl_rx_buffer,				// indicate the singal feedback from rx_fsm for next shifting
	input  logic					RXen, 
	input  logic					done_flag,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//----------------APB INTERFACE INPUT----------------//
	output logic 					data_is_avail,
	output reg   [  4 :  0]		rx_ptr_addr_wr_i,
	output reg   [  4 :  0]		rx_ptr_addr_rd_o,
	output reg   [ 11 :  0]		rx_data_o							// read data out for shift process
	//---------------------------------------------------//
);

	// Local no-need appear assignment
	reg 	[ 11:  0] mem 			[0 : 31]; 
	
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			data_is_avail <= 1'b0;
		end
		else begin
			if (rd_data_i) begin
				data_is_avail <= 1'b1;
			end
			else
				data_is_avail <= 1'b0;
		end
	end
	
	// always loop for rx_ptr_addr_wr_i increasement
	always @(posedge clk_i, negedge rst_ni) begin
		if (!rst_ni) begin
			rx_ptr_addr_wr_i <= 5'b0;
		end
		else begin
			if (RXen) begin
				if (fifo_en) begin
					if (done_flag) begin	
						rx_ptr_addr_wr_i <= rx_ptr_addr_wr_i + 5'd1; 
					end
					else
						rx_ptr_addr_wr_i <= rx_ptr_addr_wr_i;
				end
			end
		end
	end
	
	// always loop for increasing rx_ptr_addr_rd_o increasement
	always @(posedge clk_i, negedge rst_ni) begin
		if (!rst_ni) begin
			rx_ptr_addr_rd_o <= 5'b0;
		end
		else begin
			if (RXen) begin
				if (fifo_en) begin
					if (ctrl_rx_buffer) begin					// add condition for sending data out (not availabe)
						rx_ptr_addr_rd_o <= rx_ptr_addr_rd_o + 5'd1;
					end
					else	
						rx_ptr_addr_rd_o <= rx_ptr_addr_rd_o;
				end
			end
		end
	end
	
	// always loop for direct data to rx_data_o output signal
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			rx_data_o			<= 12'b0;
		end
		else begin
			if (RXen) begin
				// read out buffer operation
				if (fifo_en) begin
					rx_data_o <= mem[rx_ptr_addr_rd_o]; 
				end
				else
					rx_data_o <= rd_data_i;
			end
		end
	end

	// always loop for writing into buffer operation
	always @(posedge clk_i, negedge rst_ni) begin
	// If reset signal is active, reset all registers
		if (!rst_ni) begin           
			for (integer j = 0; j < 32; j = j + 1) begin
				mem[j] 		<= 12'b0;
			end
		end
		else begin
			if (RXen) begin
				if (fifo_en) begin
					// Write the data into RX buffer
					mem [rx_ptr_addr_wr_i]  <= rd_data_i;
				end
			end
		end
	end
	

endmodule
