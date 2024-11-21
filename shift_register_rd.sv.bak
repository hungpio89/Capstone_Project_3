module shift_register_rd		// determine whether the bit is trans when we are done
(	
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				parity_bit_mode,			// if 1 -> odd, 0-> even
	input logic					stop_bit_twice,
	input logic [  3 :  0]	number_data_receive,
	//---------------------------------------------------//
	//------------------RX FSM INPUT---------------------//
	input logic [  3 :  0]	ctrl_shift_register,		// for ctrl state sending method
	//---------------------------------------------------//
	//-----------------RX FIFO INPUT---------------------//
	input logic [ 11 :  0]	data_in,						// decide by number of data want to transfer, parity or not
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//---------------------------------------------------//
	//----------------OUTPUT TO RX FSM-------------------//
	output logic				start_bit,
	output logic				data_is_received,			// flag to indicate data is on transfer process
	output logic				parity_bit,
	output logic				stop_bit,
	//----------------OUTPUT TO UART SLAVE---------------//
	output reg	 [  7 :  0]	rx_out						// data coming into APB UART
	//---------------------------------------------------//
);

	// Local no-need appear assignment 
	
	// Logic
	logic							parity_bit_read;
	logic							done_receive_stage;
	// Register
	reg 			 [  7 :  0]	temp_reg;
	
	// check whether data is all zero or not => if data all zero (temp == 1) => data_avail is not avail, set to 0
	always @(data_in, parity_bit_mode) begin
		parity_bit_read = 1'b0;
		if (parity_bit_mode) begin
			parity_bit_read = data_in[1];
			for (int i = 2; i < 9; i++) begin
            parity_bit_read ^= data_in[i]; // XOR each bit into parity_bit_read
        end
		end
	end
	
	// shifting output related to TX FSM control unit
	always @(ctrl_shift_register, number_data_receive, data_in, stop_bit_twice, parity_bit_read) begin
	
		// reset each time checking stage operating
		start_bit 				= 1'b0;
		data_is_received 		= 1'b0;
		parity_bit 				= 1'b0;
		stop_bit					= 1'b0;
		done_receive_stage	= 1'b0;
		case (ctrl_shift_register)
			4'b0001: begin
				if (data_in[0] == 1'b0) begin							// start_bit is used at 0 (LOW Active)
					start_bit 		= 1'b1;							// this bit is used for indicate TX FSM next stage jump process (flag stage only)
				end
				else if (data_in[0] == 1'b1) begin	
					start_bit 		= 1'b0;	
				end
			end
			4'b0010: begin
				case (number_data_receive)
					4'd5: begin
						temp_reg 			= data_in[5:1];
						data_is_received 	= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
					end
					4'd6: begin
						temp_reg 			= data_in[6:1];
						data_is_received 	= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
					end
					4'd7: begin
						temp_reg 			= data_in[7:1];
						data_is_received 	= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
					end
					4'd8: begin
						temp_reg 			= data_in[8:1];
						data_is_received 	= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
					end
					default: begin	
						temp_reg 			= data_in[8:1];
						data_is_received 	= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
					end
				endcase
			end
			4'b0100: begin
				if (data_in[9] == parity_bit_read) begin			// parity_bit is used at LOW or HIGH Active depend on parity_bit_mode
					parity_bit 		= 1'b1;							// flag stage only
				end
				else
					parity_bit 		= 1'b0;
			end
			4'b1000: begin
				if (data_in[10] == 1'b1) begin							// stop_bit is used at 1 (HIGH Active)
					stop_bit					= 1'b1;							// flag stage only
					if (!stop_bit_twice) begin
						done_receive_stage 	= 1'b1;
					end
				end
				else begin
					stop_bit				= 1'b0;
				end
			end
			4'b1001: begin
				if (data_in[11] == 1'b1) begin							// stop_bit is used at 1 (HIGH Active)
					stop_bit					= 1'b1;						// flag stage only
					done_receive_stage 	= 1'b1;	
				end
				else begin
					stop_bit				= 1'b0;
				end
			end
			default:	begin												// just to specific case not making wrong data operation
				start_bit 				= 1'b0;
				data_is_received 		= 1'b0;
				parity_bit 				= 1'b0;
				stop_bit					= 1'b0;	
				done_receive_stage	= 1'b0;
			end
		endcase
	end
	
	always @(done_receive_stage, temp_reg, rx_out) begin
		if (done_receive_stage) begin
			for (int i = 0; i < 8; i = i + 1) begin: assign_temp_reg_to_release
				rx_out[i] = temp_reg[i];
			end
		end
		else
			rx_out	= rx_out;
	end
	
endmodule
