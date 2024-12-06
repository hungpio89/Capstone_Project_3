module EncoderDataLength 									// Internal module to give out the number of data used (AHB master TO AHB Bridge)
(
	// INPUT LOGIC ASSIGNMENT
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  1 :  0]	HSIZES,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------OUTPUT SIGNAL------------------//
	output logic	[  3 :  0]	SIGNAL_LENGTH			// Enable to extend later if need more
	//---------------------------------------------------//
);
	
	reg 				[  3 :  0]	mid_store_size;
	
	always @(HSIZES) begin
		mid_store_size = 4'b0;
		case(HSIZES)
			2'b00: begin										// applied for 8-bits data length
				mid_store_size = 4'b0001;
			end
			2'b01: begin										// applied for 16-bits data length
				mid_store_size = 4'b0010;
			end
			2'b10: begin										// applied for 32-bits data length
				mid_store_size = 4'b0100;
			end
			default: begin										// applied for 8-bits data length
				mid_store_size = 4'b0001;
			end
		endcase
	end
	
	assign SIGNAL_LENGTH = mid_store_size;
	
endmodule
