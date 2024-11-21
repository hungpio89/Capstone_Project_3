module uart_start_bit_detect 										// Customize block for increase legitimate of data transfer
(
	// INPUT LOGIC CONFIGURATION
	
	//-------------------CPU INPUT------------------------//
	input		logic					clk_i,        					// Clock signal
	input		logic					rst_ni,    						// Asynchronous reset, active low
	//---------------------------------------------------//
	
	//----------UART START BIT DETECT INPUT--------------//
	input		logic					UART_RXD,    					// UART RX input
	input		logic					parity_bit_mode,
	input		logic					stop_bit_twice,
	input		logic	[  3 :  0]	number_data_receive,
	input		logic					RXen,
	input		logic	[ 12 :  0]	cd,
	input 	logic					uart_mode_clk_sel,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//-----------------CONTROL OUTPUT--------------------//
	output	logic					done_flag,
	output	logic	[ 11 :  0] 	data_out    	// 12-bit output signal
	//---------------------------------------------------//
	
	// Delete later part
//	output logic 					prev_rx,              	// To store previous RX state for edge detection
//	output logic 					sampling,          		// Indicate whether to sample for start bit
//	output logic       			start_bit_detected, 		// Signal when start bit is detected
//	output logic [  1 :   0]	flag_rx_state,
//	output logic [ 11 :   0] 	shift_reg,
//	output logic [  3 :   0]	bit_count,
//	output logic [  3 :   0]	bit_count_up_to
);

	// Local no-need appear assignment 
	
	// Local logic signal define
	logic								done_ack;
	logic 							prev_rx;              	// To store previous RX state for edge detection
	logic 							sampling;          		// Indicate whether to sample for start bit
	logic       					start_bit_detected; 		// Signal when start bit is detected
	logic				[  1 :   0]	flag_rx_state;
	logic								ctrl_count_clock;
	
	// Local register signal define
	reg 				[ 11 :   0] shift_reg;
	reg    	 		[  3 :   0]	bit_count;
	reg 				[  3 :   0]	bit_count_up_to;
	reg				[ 12 :   0]	counter_clock_div2;
	
	// Always loop for assignment
	always_comb begin
		flag_rx_state	= {stop_bit_twice, parity_bit_mode};
	end
	
	// Always loop for control state
	always @(flag_rx_state, number_data_receive) begin
		bit_count_up_to	<= 4'd0;
		case (number_data_receive)
			4'd6: begin
				case (flag_rx_state)
					2'b11: begin bit_count_up_to <= 4'd9; end	// all ready minus 2 bits for exactly bit format (1 bit for start, 1 bit for arrange)
					2'b10: begin bit_count_up_to <= 4'd8; end
					2'b01: begin bit_count_up_to <= 4'd8; end
					2'b00: begin bit_count_up_to <= 4'd7; end
				endcase
			end
			4'd7: begin
				case (flag_rx_state)
					2'b11: begin bit_count_up_to <= 4'd10; end
					2'b10: begin bit_count_up_to <= 4'd9; end
					2'b01: begin bit_count_up_to <= 4'd9; end
					2'b00: begin bit_count_up_to <= 4'd8; end
				endcase
			end
			4'd8: begin
				case (flag_rx_state)
					2'b11: begin bit_count_up_to <= 4'd11; end
					2'b10: begin bit_count_up_to <= 4'd10; end
					2'b01: begin bit_count_up_to <= 4'd10; end
					2'b00: begin bit_count_up_to <= 4'd9; end
				endcase
			end
			default: begin
				case (flag_rx_state)
					2'b11: begin bit_count_up_to <= 4'd8; end
					2'b10: begin bit_count_up_to <= 4'd7; end
					2'b01: begin bit_count_up_to <= 4'd7; end
					2'b00: begin bit_count_up_to <= 4'd6; end
				endcase
			end
		endcase
	end
	
	// always loop for counting the clock divisor have passed
	always @(cd, uart_mode_clk_sel) begin
		case(uart_mode_clk_sel)
			1'b0: begin
				ctrl_count_clock 			= 1'b0;
				counter_clock_div2 		= 13'd0;
			end
			1'b1: begin
				ctrl_count_clock 			= 1'b1;
				case(cd)
					13'd5208	: counter_clock_div2 = 13'd2604;
					13'd651	: counter_clock_div2 = 13'd326;
					13'd325	: counter_clock_div2 = 13'd163;
					13'd162 	: counter_clock_div2 = 13'd162;
					13'd108 	: counter_clock_div2 = 13'd82;
					13'd81	: counter_clock_div2 = 13'd42;
					13'd54 	: counter_clock_div2 = 13'd28;
					13'd27	: counter_clock_div2 = 13'd14;
					13'd13	: counter_clock_div2 = 13'd7;
					13'd6		: counter_clock_div2 = 13'd4;
					13'd3		: counter_clock_div2 = 13'd2;					// Maximum cd for normal UART
					13'd325  : counter_clock_div2 = 13'd163;				// default 9600 -> count to half
				endcase
			end
		endcase
	end
	
	// always loop for detect start bit for recording
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			prev_rx 					<= 1'b1;              // Initial state: RX is idle
			start_bit_detected 	<= 1'b0;
			sampling 				<= 1'b0;
		end 
		else begin
			if (RXen) begin
				if (!done_flag) begin
					// Edge detection: Detect falling edge from '1' to '0' (start bit)
					if (prev_rx && !UART_RXD && !ctrl_count_clock) begin
						sampling <= 1'b1;          // Start sampling
					end
					else if (prev_rx && !UART_RXD && ctrl_count_clock) begin
						
					end

					prev_rx <= UART_RXD;  // Update previous RX state for next clock cycle

					// Sampling logic to confirm the start bit
					if (sampling) begin
						start_bit_detected <= 1'b1;  // Start bit confirmed
					end 
					else begin
						start_bit_detected <= 1'b0;  // False alarm, reset
					end
				end
				else begin
					prev_rx 					<= 1'b1; 
					start_bit_detected 	<= 1'b0;
					sampling 				<= 1'b0;
				end
			end
		end
	end
	
	// always loop for assignment bit when start bit is detected 
	always @(posedge clk_i or negedge rst_ni) begin
		if (!rst_ni) begin
			shift_reg 	<= 12'b0;     		// Reset shift register
			bit_count 	<= 4'd0;        	// Reset bit counter
			done_flag	<= 1'b0;
		end
		else begin
			done_flag		<= 1'b0;
			shift_reg[0] 	<= 1'b0;
			if (start_bit_detected) begin
				shift_reg[bit_count + 4'd1] <= prev_rx;
				
				// Increment bit counter
				bit_count <= bit_count + 4'b1;
				
				// Once 12 bits are collected, send the result and reset counter
				if (bit_count == bit_count_up_to) begin
					bit_count 	<= 4'd0;
					done_flag	<= 1'b1;
				end
			end
			else
				bit_count 	<= 4'd0;
		end
	end
	
	always @(done_flag, shift_reg, data_out) begin
		if (done_flag) begin
			for (int i = 0; i < 12; i = i + 1) begin
				data_out[i] <= shift_reg[i];
			end
		end
		else
			data_out	<= data_out;
	end
	
endmodule
