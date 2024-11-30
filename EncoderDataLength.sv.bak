module EncoderDataLength 									// Internal module to give out the number of data used (AHB master TO AHB Bridge)
(
	// INPUT LOGIC ASSIGNMENT
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  2 :  0]	HSIZES,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------OUTPUT SIGNAL------------------//
	output reg 		[  5 :  0]	SIGNAL_LENGTH			// Enable to extend later if need more
	//---------------------------------------------------//
);
	
	reg 				[  5 :  0]	mid_store_size;
	
	always @(*) begin
		case(HSIZES)
			3'b000: begin										// applied for 8-bits data length
				mid_store_size = 6'b0000_01;
			end
			3'b001: begin										// applied for 16-bits data length
				mid_store_size = 6'b0000_10;
			end
			3'b010: begin										// applied for 32-bits data length
				mid_store_size = 6'b0001_00;
			end
			3'b011: begin										// applied for 64-bits data length
				mid_store_size = 6'b0010_00;
			end
			3'b100: begin										// applied for 128-bits data length
				mid_store_size = 6'b0100_00;
			end
			3'b101: begin										// applied for 256-bits data length
				mid_store_size = 6'b1000_00;
			end
			default: begin										// applied for 8-bits data length
				mid_store_size = 6'b0000_01;
			end
		endcase
	end
	
	assign SIGNAL_LENGTH = mid_store_size;
	
endmodule
