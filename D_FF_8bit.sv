module D_FF_8bit					// used only for APB UART
(	
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input  logic        		   rst_ni,
	//---------------------------------------------------//
	//--------------BAUD RATE GEN INPUT------------------//
	input  logic       		   clk_i,
	//------------------TX FSM INPUT---------------------//
	input  logic        		   enable, 	
	//---------------------------------------------------//
	//-----------------TX FIFO INPUT---------------------//
	input  logic 	[ 7 : 0] 	D,
	//---------------------------------------------------//
	
	//OUTPUT LOGIC ASSIGNMENT
	
	//------------------UART RETURN----------------------//
	output reg 		[ 7 : 0] 	Q
	//---------------------------------------------------//
);

	logic 			[ 7 : 0] 	q_reg;                 // Register to hold the output data
	
	always_ff @(posedge clk_i or negedge rst_ni) begin
		if(!rst_ni) begin
			q_reg  <= 8'b0;
		end
		else begin
			if (!enable) begin		   // if the running process is on transfer
				q_reg  <= q_reg;
			end	
			else							// if the TX FSM send back to enable continue index ptr for write to UART Slave
				q_reg  <= D;
		end
	end
	
	assign Q = q_reg;
	
endmodule
