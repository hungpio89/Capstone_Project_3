module EncoderAddressBehave 									// Internal module to port out the behavior of address gen (AHB master TO AHB Bridge)
(
	// INPUT LOGIC ASSIGNMENT
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  2 :  0]	HBURST,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------OUTPUT SIGNAL------------------//
	output reg 		[  7 :  0]	SIGNAL_BEHAVIOR			// Enable to extend later if need more
	//---------------------------------------------------//
);
	
	reg 				[  7 :  0]	mid_store_behave;
	
	always @(*) begin
		case(HBURST)
			3'b000: begin										// applied for SINGLE TRANSFER MODE
				mid_store_behave = 8'b0000_0001;
			end
			3'b001: begin										// applied for INCREMENTING BURST OF UNSPECIFIED LENGTH
				mid_store_behave = 8'b0000_0010;
			end
			3'b010: begin										// applied for 4-BEAT WRAPPING BURST
				mid_store_behave = 8'b0000_0100;
			end
			3'b011: begin										// applied for 4-BEAT INCREMENTING BURST
				mid_store_behave = 8'b0000_1000;
			end
			3'b100: begin										// applied for 8-BEAT WRAPPING BURST
				mid_store_behave = 8'b0001_0000;
			end
			3'b101: begin										// applied for 8-BEAT INCREMENTING BURST
				mid_store_behave = 8'b0010_0000;
			end
			3'b110: begin										// applied for 16-BEAT WRAPPING BURST
				mid_store_behave = 8'b0100_0000;
			end
			3'b111: begin										// applied for 16-BEAT INCREMENTING BURST
				mid_store_behave = 8'b1000_0000;
			end
		endcase
	end
	
	assign SIGNAL_BEHAVIOR = mid_store_behave;
	
endmodule
