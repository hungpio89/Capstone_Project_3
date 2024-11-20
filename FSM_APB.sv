module FSM_APB
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				PCLK,						// input clk_i from CPU (interface with rising-edge)
	input logic 				PRESETn,					// input rst_ni from CPU
	//---------------------------------------------------//
	
	//-----------------INPUT FROM COMPLETER--------------//
	input logic 				transfer,				// indicate start transfer process depend on PADDR, PWRITE, PWDATA
	input logic 				PREADY,					// indicates an APB write ACCESS when HIGH (1) and an APB read ACCESS when LOW (0)
	//---------------------------------------------------//
	
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	output logic 				PENABLE,					// indicates second and subsequent cycles of an APB transfer
	output logic 				PSELx						// indicates that the completer is selected and that a data transfer is require
	//---------------------------------------------------//
	
);

	// Internal logic define
	

	// Local Logic Assignment
	
	// state declaration communication
	typedef enum bit[1:0] {IDLE, SETUP, ACCESS}	state;
  
	//state declaration of present and next 
	state present_state, next_state;
  
	always_ff @(posedge PCLK or negedge PRESETn) begin
		if(!PRESETn) begin			// back to IDLE state
			present_state <= IDLE;
		end
		else begin
			present_state <= next_state;
		end
	end
	
	always @(present_state, transfer, PREADY) begin
		
		// reset all reg
		PSELx  		= 0;
		PENABLE 		= 0;
		
		case (present_state)
			IDLE: begin
				if (!transfer) begin 	
					next_state = IDLE;
				end
				else 
					next_state = SETUP;
			end

			SETUP: begin 	
					next_state = ACCESS;
					PSELx  	  = 1;
					PENABLE    = 0;
			end
			
			ACCESS: begin
				if (!PREADY) begin 	
					next_state = ACCESS;
					PSELx  = 1;
					PENABLE = 1;
				end
				else begin
					if (!transfer) begin 	
						next_state = IDLE;
					end
					else 
						next_state = SETUP;
				end
			end
		endcase 
	end
	
endmodule
