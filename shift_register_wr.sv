module shift_register_wr		// determine whether the bit is trans when we are done
(	
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				parity_bit_mode,			// if 1 -> acitve, 0 -> deactive
	//---------------------------------------------------//
	//-----------------TX FSM INPUT----------------------//
	input logic [  3 :  0]	ctrl_shift_register,		// for ctrl state sending method
	input logic [  3 :  0]	tick_count,					// counter custom for debugging
	//---------------------------------------------------//
	//-----------------TX FIFO INPUT---------------------//
	input logic [  7 :  0] 	data_in,						// decide by number of data want to transfer, parity or not
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//---------------------------------------------------//
	//----------------OUTPUT TO TX FSM-------------------//
	output logic				start_bit,
	output logic				data_on_trans,				// flag to indicate data is on transfer process
	output logic				parity_bit,
	output logic				stop_bit,
	//----------------OUTPUT TO UART SLAVE---------------//
	output reg					tx_out						// data coming out from APB UART
	//---------------------------------------------------//
);
	
	//
	logic							parity_bit_send;
	
	// check whether data is all zero or not => if data all zero (temp == 1) => data_avail is not avail, set to 0
	always @(data_in, parity_bit_mode) begin
		parity_bit_send = 1'b0;
		if (parity_bit_mode) begin
			parity_bit_send = data_in[0];
			for (int i = 1; i < 8; i++) begin
            parity_bit_send ^= data_in[i]; // XOR each bit into parity_bit_send
        end
		end
	end
	
	// shifting output related to TX FSM control unit
	always @(ctrl_shift_register, data_in, tick_count, parity_bit_send) begin
		// reset each time checking stage operating
		start_bit 		<= 1'b0;
		data_on_trans 	<= 1'b0;
		parity_bit 		<= 1'b0;
		stop_bit			<= 1'b0;
		tx_out			<= 1'b0;
		case (ctrl_shift_register)
			4'b0001: begin
				tx_out				<= 1'b0;			// start bit always low related to Reference's Docs
				start_bit 			<= 1'b1;			// this bit is used for indicate TX FSM next stage jump process (flag stage only)
			end
			4'b0010: begin
				if (tick_count) begin				// not 0 (tick count is set by TX FSM to indicate the # of bit need to send) -> 8 bits sending mode
					tx_out 			<= data_in[tick_count - 4'b1];
					data_on_trans 	<= 1'b1;			// this bit is used for indicate TX FSM next stage jump process
				end			
				else if (!tick_count)
					data_on_trans	<= 1'b0;
			end
			4'b0100: begin
				tx_out 				<= parity_bit_send;	// related to parity mode for sending out 
				parity_bit 			<= 1'b1;					// flag stage only
			end
			4'b1000: begin
				tx_out 				<= 1'b1;			// stop bit always high related to Reference's Docs
				stop_bit				<= 1'b1;			// flag stage only
			end
			default:	begin								// just to specific case not making wrong data operation
				tx_out 				<= 1'b1;
				start_bit 			<= 1'b0;
				data_on_trans 		<= 1'b0;
				parity_bit 			<= 1'b0;
				stop_bit				<= 1'b0;
			end
		endcase
	end

endmodule
