module tx_fsm
(
	// INPUT LOGIC CONFIGURATION
	
	//----------------INPUT FROM BAUD GEN ---------------//
	input logic 				baud_tick,
	//---------------------------------------------------//
	//------------------CPU INPUT------------------------//
	input logic 				PRESETn,
	input logic 				stop_bit_twice,
	input logic					parity_bit_mode,
	input logic 				TXen, 
	input logic					PWRITE,
	//---------------------------------------------------//
	//-------------INPUT FROM SHIFT REGISTER ------------//
	input logic 				start_bit,
	input logic	 				data_on_trans,
	input logic 				parity_bit,
	input logic 				stop_bit,			// indicate stop bit
	//---------------------------------------------------//
	//-----------------INPUT FROM MASTER-----------------//
	input logic [ 3  :  0]	number_data_trans,
	//---------------------------------------------------//
	// OUTPUT LOGIC CONFIGURATION
	
	//---------------------TX FSM OUT--------------------//
	output logic [ 3 :  0]	ctrl_shift_register,		// output signal feedback to shift register indicate shift process operating bit[0] ~ start_bit  request
															// 																								  bit[1] ~ data_bit   request
															// 																								  bit[2] ~ parity_bit request
															// 																								  bit[3] ~ stop_bit   request
	output logic 				ctrl_tx_buffer,	// output signal indicate enable output data process from TX FIFO
	output logic [ 3 :  0] 	tick_count,
	output logic 				error_tx_detect,
	output logic 				done_tx
	//---------------------------------------------------//
);
	// Local logic definition
	logic 						flag_trans_sixth_tx_state;
	logic 						flag_trans_seventh_tx_state;
	logic 						flag_trans_eighth_tx_state;
	
	// state declaration communication
	typedef enum bit[ 3 :  0] {IDLE, START, DATA0, DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7, PARITY, STOP_0, STOP_1, ERROR}	state;	// Total 14 state, LOAD <=> START
  
	state present_state, next_state;
	
	always_ff @(posedge baud_tick or negedge PRESETn) begin
		if(!PRESETn) begin			// back to IDLE state
			present_state <= IDLE;
		end
		else begin
			if (PWRITE) begin
				present_state <= next_state; 
			end
			else
				present_state <= ERROR;
		end
	end
	
	always @(number_data_trans) begin
		flag_trans_sixth_tx_state 				<= 1'b0;
		flag_trans_seventh_tx_state 			<= 1'b0;
		flag_trans_eighth_tx_state				<= 1'b0;
		case (number_data_trans)
			4'd6: begin
				flag_trans_sixth_tx_state 		<= 1'b1;
			end
			4'd7: begin
				flag_trans_sixth_tx_state 		<= 1'b1;
				flag_trans_seventh_tx_state 	<= 1'b1;
			end
			4'd8: begin
				flag_trans_sixth_tx_state 		<= 1'b1;
				flag_trans_seventh_tx_state 	<= 1'b1;
				flag_trans_eighth_tx_state 	<= 1'b1;
			end
			default: begin
				flag_trans_sixth_tx_state 		<= 1'b0;
				flag_trans_seventh_tx_state 	<= 1'b0;
				flag_trans_eighth_tx_state		<= 1'b0;
			end
		endcase
	end
	
	always @(present_state, TXen, start_bit, data_on_trans, stop_bit, parity_bit, parity_bit_mode, stop_bit_twice, flag_trans_sixth_tx_state, flag_trans_seventh_tx_state, flag_trans_eighth_tx_state) begin
		ctrl_shift_register 	= 4'b0;
		tick_count	   		= 4'b0;
		ctrl_tx_buffer 		= 1'b0;
		done_tx					= 1'b0;
		error_tx_detect	   = 1'b0;
		next_state				= IDLE;
		case (present_state) 
			IDLE: begin
				if (!TXen) begin
					next_state = IDLE;
				end
				else if (TXen) begin
					ctrl_shift_register 	= 4'b0000;
					next_state 				= START;
					ctrl_tx_buffer 		= 1'b1;
				end
			end
			
			START: begin
				ctrl_shift_register = 4'b0001;			// enable shift register shift start bit
				if (!start_bit) begin						// check count of bit number
					next_state = START;
				end
				else if (start_bit) begin
					next_state = DATA0;
				end
			end
			
			DATA0: begin
				ctrl_shift_register = 4'b0010;	
				tick_count = 4'd1;
				if (data_on_trans) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA1;
				end
				else if (!data_on_trans) begin
					next_state = ERROR;
				end
			end
		
			DATA1: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd2;	
				if (data_on_trans) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA2;
				end
				else if (!data_on_trans ) begin
					next_state = ERROR;
				end
			end
			
			DATA2: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd3;	
				if (data_on_trans) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA3;
				end
				else if (!data_on_trans) begin
					next_state = ERROR;
				end
			end
		
			DATA3: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd4;	
				if (data_on_trans) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA4;
				end
				else if (!data_on_trans) begin
					next_state = ERROR;
				end
			end
			
			DATA4: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd5;	
				if (data_on_trans && flag_trans_sixth_tx_state) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA5;
				end
				else if (data_on_trans && !flag_trans_sixth_tx_state && parity_bit_mode) begin	
					next_state = PARITY;
				end
				else if (data_on_trans && !flag_trans_sixth_tx_state && !parity_bit_mode) begin	
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
		
			DATA5: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd6;	
				if (data_on_trans  && flag_trans_seventh_tx_state) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA6;
				end
				else if (data_on_trans && !flag_trans_seventh_tx_state && parity_bit_mode) begin	
					next_state = PARITY;
				end
				else if (data_on_trans && !flag_trans_seventh_tx_state && !parity_bit_mode) begin	
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			DATA6: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd7;	
				if (data_on_trans  && flag_trans_eighth_tx_state) begin			// CHECK FLAG OF SHIFT DONE
					next_state = DATA7;
				end
				else if (data_on_trans && !flag_trans_eighth_tx_state && parity_bit_mode) begin	
					next_state = PARITY;
				end
				else if (data_on_trans && !flag_trans_eighth_tx_state && !parity_bit_mode) begin	
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
		
			DATA7: begin
				ctrl_shift_register = 4'b0010;
				tick_count = 4'd8;	
				if (data_on_trans && parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = PARITY;
				end
				else if (data_on_trans && !parity_bit_mode) begin			// CHECK FLAG OF SHIFT DONE
					next_state = STOP_0;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			PARITY: begin
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
				if (stop_bit && stop_bit_twice) begin
					next_state = STOP_1;
				end
				else if (stop_bit && !stop_bit_twice) begin
					next_state 		= IDLE;
//					ctrl_tx_buffer = 1'b1;
					done_tx 	  		= 1'b1;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			STOP_1: begin
				ctrl_shift_register = 4'b1000;
				if (stop_bit) begin
					next_state 		= IDLE;
//					ctrl_tx_buffer = 1'b1;
					done_tx 	  		= 1'b1;
				end
				else begin
					next_state = ERROR;
				end
			end
			
			ERROR: begin
				error_tx_detect	= 1'b1;
				next_state 			= IDLE;
			end
			
		endcase
	end
  
endmodule
