module FSM_AHB	// Advanced High Performance Bus
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input logic 				HCLK,						// input clk_i from CPU (interface with rising-edge)
	input logic 				HRESETn,					// input rst_ni from CPU
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic					Valid,					// indicate VALID when the AHB contains a valid APB read/write transfer
	input logic 				HWRITE,					// indicates an AHB write ACCESS when HIGH (1) and an AHB read ACCESS when LOW (0)
	//---------------------------------------------------//
	
	//-----------------INPUT FROM SLAVE------------------//
	input logic					PREADY,
	//---------------------------------------------------//
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	output reg 					HwriteReg,
	output reg					HREADYout,
	output logic 				APBen,					// signal is used as an enable on the PSEL, PWRITE and PADDR output registers
	output logic 				PENABLE,					// indicates second and subsequent cycles of an APB transfer
	output logic 				PSELx,					// indicates that the completer is selected and that a data transfer is require -> get into Address decode (further detail)
	output logic 				PWRITE					// indicates an APB write ACCESS when HIGH (1) and an APB read ACCESS when LOW (0)
	//---------------------------------------------------//
	
);
	// Local Signal declaration for communication
	// state declaration communication
	//															READ_EN  	WRITE_EN	  WRITE_W   WR_P			WR_EN_P
	typedef enum bit[2:0] {ST_IDLE, ST_READ, ST_WRITE, ST_RENABLE, ST_WENABLE, ST_WWAIT, ST_WRITEP, ST_WENABLEP} state;
  
	//state declaration of present and next 
	state present_state, next_state;

	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin			// back to ST_IDLE state
			present_state <= ST_IDLE;
		end
		else begin
			present_state <= next_state;
		end
	end
	
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			HwriteReg <= 0;
			HREADYout <= 0;
		end
		else begin
			HwriteReg <= HWRITE;
			HREADYout <= PREADY;
		end
	end
	
	always @(present_state, Valid, HwriteReg, HWRITE) begin
		// reset all reg
		PENABLE	  = 0;
		PSELx		  = 0;
		PWRITE	  = 0;
		APBen		  = 0;
		// BEGIN STATE OPERATION
		case (present_state)
			ST_IDLE: begin							// this state enter via reset, when the system is initialized
				APBen		  = 0;
				PSELx		  = 0;
				case (Valid) 
					1: begin 
						if (!HWRITE) begin 	
							next_state 		= ST_READ;
						end
						else 
							next_state = ST_WWAIT;
					end
					0: begin
						next_state 		= ST_IDLE;
						PENABLE	  		= 0;
						PSELx		  		= 0;
					end
				endcase
			end

			ST_READ: begin 						// this state serve for a read transfer
				next_state = ST_RENABLE;
				PENABLE	  = 1;
				APBen		  = 1;
				PSELx		  = 1;
				PWRITE	  = 0;
			end
			
			ST_WWAIT: begin 						// this state needed due to the pipelined structure of AHB transfers
				APBen		  = 0;
				PSELx		  = 0;
				PWRITE	  = 1;
				case (Valid) 
					1: begin 
						next_state = ST_WRITEP;
					end
					0: begin
						next_state = ST_WRITE;
					end
				endcase
			end
			
			ST_WRITE: begin						// During this state the address is decoded and driven onto PADDR
				APBen		  = 1;
				PSELx		  = 1;
				PWRITE	  = 1;
				PENABLE	  = 1;
				case (Valid) 
					1: begin
						next_state = ST_WENABLEP;
					end
					0: begin
						next_state = ST_WENABLE;
					end
				endcase
			end
			
			ST_WRITEP: begin						// During this state the address is decoded and driven onto PADDR
				PSELx		  = 1;
				PWRITE	  = 1;
				APBen		  = 1;
				PENABLE	  = 1;
				next_state = ST_WENABLEP;
			end
			
			ST_RENABLE: begin
				PSELx		  = 1;
				PENABLE	  = 1;
				APBen		  = 1;
				PWRITE	  = 0;
				case (Valid) 
					1: begin 
						if (!HWRITE) begin 	
							next_state = ST_READ;
						end
						else 
							next_state = ST_WWAIT;
					end
					0: begin
						next_state = ST_IDLE;
					end
				endcase
			end
			
			ST_WENABLE: begin
				APBen		  = 1;
				PSELx		  = 1;
				PWRITE	  = 1;
				PENABLE	  = 1;
				case (Valid) 
					1: begin 
						if (!HwriteReg) begin 	
							next_state = ST_READ;
						end
						else 
							next_state = ST_WWAIT;
					end
					0: begin
						next_state = ST_IDLE;
					end
				endcase
			end
			
			ST_WENABLEP: begin
				APBen		  = 0;
				PENABLE	  = 1;
				PWRITE	  = 1;
				PSELx		  = 1;
				case (HwriteReg) 
					1: begin 
						if (!Valid) begin 	
							next_state = ST_WRITE;
						end
						else 
							next_state = ST_WRITEP;
					end
					0: begin
						next_state = ST_READ;
					end
				endcase
			end
		endcase 
	end
	
endmodule
