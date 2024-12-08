module encoder_method
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input 	logic 	[	2 :  0] 	HBURST,
	input 	logic						HCLK,
	input 	logic						HRESETn,
	input 	logic						enable,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC ASSIGNMENT
	
	//------------------OUTPUT TO SLAVE------------------//
	output 	logic		[ 31 :  0]	HADDR
	//---------------------------------------------------//
);
	reg 					[ 31 :  0]	HADDR_temp;

	typedef enum bit[ 2 : 0] {SINGLE = 3'b000, INCR = 3'b001, WRAP4 = 3'b010, INCR4 = 3'b011, WRAP8 = 3'b100, INCR8 = 3'b101, WRAP16 = 3'b110, INCR16 = 3'b111} Type;		// this is used for HBURST
	
	Type ctrl_addr;
	
	// Internal signal for edge detection
	logic signal_in_d;
	
	// Rising edge detection
	wire rising_edge;

	// Edge detection
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			signal_in_d <= 0;
		end 
		else begin
			signal_in_d <= enable;
		end
	end

	assign rising_edge = enable & ~signal_in_d;
	
	// Always loop control state
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			HADDR_temp <= 32'h8000_0400;
		end
		else begin
			if (rising_edge) begin
				case (HBURST)
					SINGLE: begin
						HADDR_temp = 32'h8000_0400;
					end
					INCR: begin
						HADDR_temp = HADDR_temp + 32'd4;
					end
					WRAP4: begin
						if (HADDR_temp[6] && !HADDR_temp[4]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4 ;
					end
					INCR4: begin
						if (HADDR_temp[6]&& HADDR_temp[4] && HADDR_temp[2]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4;
					end
					WRAP8: begin
						if (HADDR_temp[6] && HADDR_temp[4] && HADDR_temp[3] && HADDR_temp[2]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4;
					end
					INCR8: begin
						if (HADDR_temp[6]&& HADDR_temp[5] && HADDR_temp[2]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4;
					end
					WRAP16: begin
						if (HADDR_temp[6] && HADDR_temp[5] && HADDR_temp[4] && HADDR_temp[3] && HADDR_temp[2]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4;
					end
					INCR16: begin
						if (HADDR_temp[7] && HADDR_temp[2]) begin
							HADDR_temp = 32'h8000_0400;
						end
						else
							HADDR_temp = HADDR_temp + 32'd4;
					end
				endcase
			end
			else
				HADDR_temp = HADDR_temp;
		end
	end
	
	genvar m;
	generate
		for (m = 0; m < 32; m = m + 1) begin: assign_for_output
			assign HADDR[m] = HADDR_temp[m];
		end
	endgenerate
	
endmodule
