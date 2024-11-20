module D_FF_12bit					// used only for APB UART
(	
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input  logic        		   rst_ni,
	//---------------------------------------------------//
	//--------------BAUD RATE GEN INPUT------------------//
	input  logic       		   baud_tick,
	//------------------TX FSM INPUT---------------------//
	input  logic        		   enable, 	
	//---------------------------------------------------//
	//-----------------TX FIFO INPUT---------------------//
	input  logic 	[ 11 : 0] 	D,
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//------------------UART RETURN----------------------//
	output reg 		[ 11 : 0] 	Q
	//---------------------------------------------------//
);
	always_ff @(posedge baud_tick or negedge rst_ni) begin
		if(!rst_ni) begin
			Q  <= 12'b0;
		end
		else begin
			if (!enable) begin		   // if the running process is on transfer
				Q  <= Q;
			end	
			else							// if the TX FSM send back to enable continue index ptr for write to UART Slave
				Q  <= D;
		end
	end
endmodule
