module custom_fsm_wr_rd									// CUSTOM from APB interface FSM
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				PCLK,						// input clk_i from CPU (interface with rising-edge)
	input logic 				PRESETn,					// input rst_ni from CPU
	//---------------------------------------------------//
	
	//-----------------INPUT FROM COMPLETER--------------//
	input logic 				transfer,				// indicate start transfer process depend on PADDR, PWRITE, PWDATA
	input logic 				PREADY,					// indicates an APB write WAIT when HIGH (1) and an APB read WAIT when LOW (0)
	input logic  [  1 :  0]	ctrl,						// bit 0 & 1 of ctrl only
	input logic					uart_run_flag, 		// indicate transmit & receive method is available
	input logic					PWRITE,
	//---------------------------------------------------//
	
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	output logic 				TXen,						// indicates second and subsequent cycles of an APB transfer
	output logic 				RXen						// indicates that the completer is selected and that a data transfer is require
	//---------------------------------------------------//
	
);

	// Local no-need appear assignment
	
	
	// state declaration communication
	typedef enum bit[2:0] {IDLE, TRANS, READ, RWAIT, WWAIT, ERROR}	state;
  
	//state declaration of present and next 
	state present_state, next_state;
  
  // always loop for state transition
	always @(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn) begin			// back to IDLE state
			present_state <= IDLE;
		end
		else begin
			if (uart_run_flag) begin
				present_state <= next_state;
			end
			else 
				present_state <= IDLE;
		end
	end
	
	// always loop for state operation
	always @(present_state, PWRITE, transfer, PREADY, ctrl) begin
		
		// reset all signal
		TXen  	= 0;
		RXen 		= 0;
		
		case (present_state)
			IDLE: begin
				if (!transfer) begin
					next_state = IDLE;
				end
				else begin
					case (ctrl)
						2'b01: begin					// Transmit data only
							if (PWRITE) begin
								next_state = TRANS;
							end
							else
								next_state = IDLE;
						end
						
						2'b10: begin
							if (!PWRITE) begin
								next_state = READ;
							end
							else
								next_state = IDLE;
						end
						
						2'b11: begin
							if (PWRITE) begin
								next_state = TRANS;
							end
							else if (!PWRITE) begin
								next_state = READ;
							end
						end
						
						default: begin
							next_state = ERROR;
						end
					endcase
				end
			end

			TRANS: begin 	
				if (PWRITE) begin
					next_state = WWAIT;
					TXen       = 1;
				end
				else
					next_state = IDLE;
			end
			
			READ: begin 
				if (!PWRITE) begin	
					next_state = RWAIT;
					RXen       = 1;
				end
				else
					next_state = IDLE;
			end
			
			WWAIT: begin
				if (!PREADY && PWRITE) begin 	
					next_state = WWAIT;
					TXen       = 1;
				end
				else
					next_state = IDLE;
			end
			
			RWAIT: begin
				if (!PREADY  && !PWRITE) begin 	
					next_state = RWAIT;
					RXen       = 1;
				end
				else 
					next_state = IDLE;
			end
			
			ERROR: begin
				next_state	= IDLE;
			end
			
		endcase 
	end
	
endmodule
