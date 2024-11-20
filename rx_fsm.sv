module rx_fsm
(
	// INPUT LOGIC CONFIGURATION
	
	//----------------INPUT FROM BAUD GEN ---------------//
	input logic 				baud_tick,
	//---------------------------------------------------//
	//------------------CPU INPUT------------------------//
	input logic 				PRESETn,
	input logic 				parity_bit_mode,
	input logic					stop_bit_twice,
	input logic					data_is_avail,
	input logic 				RXen, 
	input logic					PWRITE,
	//---------------------------------------------------//
	//-------------INPUT FROM SHIFT REGISTER ------------//
	input logic 				start_bit,
	input logic	 				data_is_received,
	input logic 				parity_bit,
	input logic 				stop_bit,			// indicate stop bit
	//---------------------------------------------------//
	//---------------INPUT FROM MASTER ------------------//
	input logic  [ 3 :  0]	number_data_receive,
	//---------------------------------------------------//
	// OUTPUT LOGIC CONFIGURATION
	
	//---------------------TX FSM OUT--------------------//
	output logic [ 3 :  0]	ctrl_shift_register,		// output signal feedback to shift register indicate shift process operating bit[0] ~ start_bit  request
															// 																								  bit[1] ~ data_bit   request
															// 																								  bit[2] ~ parity_bit request
															// 																								  bit[3] ~ stop_bit   request
	output logic 				ctrl_rx_buffer,	// output signal indicate enable output data process from TX FIFO
	output logic 				error_rx_detect,
	output logic 			 	timeout_flag,
	output logic 				rx_done
	//---------------------------------------------------//
);
	// Local logic definition
//	logic 		 [ 1 :  0]  rx_state;	
	
	logic 						flag_received_sixth_tx_state;
	logic 						flag_received_seventh_tx_state;
	logic 						flag_received_eighth_tx_state;
	
	// state declaration communication
	typedef enum bit[ 4 :  0] {IDLE, START, DATA_IS_5, DATA_IS_6, DATA_IS_7, DATA_IS_8, PARITY, STOP_0, STOP_1, ERROR, TIMEOUT, DONE}	state;	// Total 12 state, LOAD <=> START
  
	state present_state, next_state;
	
	always_ff @(posedge baud_tick or negedge PRESETn) begin
		if(!PRESETn) begin			// back to IDLE state
			present_state <= IDLE;
		end
		else begin
			if (!PWRITE && RXen) begin
				present_state <= next_state; 
			end
			else if (PWRITE && RXen) begin
				present_state <= ERROR;
			end
			else
				present_state <= IDLE; 
		end
	end
	
	always @(number_data_receive) begin
		flag_received_sixth_tx_state 				<= 1'b0;
		flag_received_seventh_tx_state 			<= 1'b0;
		flag_received_eighth_tx_state				<= 1'b0;
		case (number_data_receive)
			4'd6: begin
				flag_received_sixth_tx_state 		<= 1'b1;
			end
			4'd7: begin
				flag_received_sixth_tx_state 		<= 1'b1;
				flag_received_seventh_tx_state 	<= 1'b1;
			end
			4'd8: begin
				flag_received_sixth_tx_state 		<= 1'b1;
				flag_received_seventh_tx_state 	<= 1'b1;
				flag_received_eighth_tx_state 	<= 1'b1;
			end
			default: begin			// related to less and equal 5
				flag_received_sixth_tx_state 		<= 1'b0;
				flag_received_seventh_tx_state 	<= 1'b0;
				flag_received_eighth_tx_state		<= 1'b0;
			end
		endcase
	end
	
	always @(present_state, data_is_avail, RXen, start_bit, data_is_received, parity_bit, parity_bit_mode, stop_bit_twice, stop_bit, flag_received_sixth_tx_state, flag_received_seventh_tx_state, flag_received_eighth_tx_state) begin
		ctrl_shift_register 		= 4'b0;
		rx_done						= 1'b0;
		ctrl_rx_buffer 			= 1'b0;
		error_rx_detect 			= 1'b0;
		timeout_flag				= 1'b0;

		case (present_state) 
			IDLE: begin
				if (!RXen) begin
					next_state = IDLE;
				end
				else if (RXen & data_is_avail) begin
					next_state = START;
				end
			end
			START: begin
				ctrl_shift_register = 4'b0001;			// enable shift register shift start bit
				if (!start_bit) begin
					next_state = START;
				end
				else if (start_bit && flag_received_sixth_tx_state) begin
					next_state = DATA_IS_6;
				end
				else if (start_bit && flag_received_seventh_tx_state) begin
					next_state = DATA_IS_7;
				end
				else if (start_bit && flag_received_eighth_tx_state) begin
					next_state = DATA_IS_8;
				end
				else if (start_bit) begin
					next_state = DATA_IS_5;
				end
			end
			DATA_IS_5: begin
				ctrl_shift_register = 4'b0010;
				if (data_is_received && parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = PARITY;
				end
				else if (data_is_received && !parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
		
			DATA_IS_6: begin
				ctrl_shift_register = 4'b0010;
				if (data_is_received && parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = PARITY;
				end
				else if (data_is_received && !parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			DATA_IS_7: begin
				ctrl_shift_register = 4'b0010;
				if (data_is_received && parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = PARITY;
				end
				else if (data_is_received && !parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			DATA_IS_8: begin
				ctrl_shift_register = 4'b0010;
				if (data_is_received && parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = PARITY;
				end
				else if (data_is_received && !parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			PARITY: begin	// only 1 time check parity receive
				ctrl_shift_register = 4'b0100;
				if (!parity_bit) begin
					next_state = ERROR;
				end
				else if (parity_bit) begin
					next_state = STOP_0;
				end
			end
			
			STOP_0: begin
				ctrl_shift_register = 4'b1000;
				if (stop_bit && !stop_bit_twice) begin
					next_state 		= IDLE;
					ctrl_rx_buffer = 1'b1;			// enable the TX buffer to receive data from D - FF intermediate
					rx_done			= 1'b1;
				end
				else if (stop_bit && stop_bit_twice) begin
					next_state 		= STOP_1;
				end
				else begin								// if check # of parity bit is not enough
					next_state = ERROR;
				end
			end
			
			STOP_1: begin
				ctrl_shift_register = 4'b1001;
				if (stop_bit) begin
					ctrl_rx_buffer = 1'b1;			// enable the TX buffer to receive data from D - FF intermediate
					rx_done			= 1'b1;
					next_state 		= IDLE;	
				end
				else begin
					next_state = ERROR;
				end
			end
			
			TIMEOUT: begin
				next_state 		 = IDLE;
				timeout_flag 	 = 1'b1;
				error_rx_detect = 1'b1;
			end
			
			ERROR: begin
				next_state 		 = IDLE;
				error_rx_detect = 1'b1;
			end
			
		endcase
	end
  
endmodule
