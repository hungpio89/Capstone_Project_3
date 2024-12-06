module DataLengthDecoder 										// This block is an customize module only used for interupt data length
(
	// INPUT LOGIC ASSIGNMENT
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic 					HCLK,
	input logic						HRESETn,
	input logic						HWriteReg,
	input logic 	[ 31 :  0]	HWDATA,
	//---------------------------------------------------//
	
	//---------INPUT FROM INTERNAL ENCODER BLOCK---------//
	input logic		[  3 :  0]	SIGNAL_LENGTH,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------OUTPUT SIGNAL------------------//
	output reg 		[  31 :  0]	PWDATA						// Enable to extend later if need more
	//---------------------------------------------------//
);
	
	reg 				[  31 :  0]	mid_pwdata;	
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin
			mid_pwdata  <=  32'd0;
		end
		else begin
			if (HWriteReg) begin
				for (int i = 0; i < 32; i = i + 1) begin: assign_32_generate
					mid_pwdata[i] <= HWDATA[i];
				end
			end
			else
				mid_pwdata <= mid_pwdata;
		end
	end
	
	always @(SIGNAL_LENGTH, mid_pwdata, HWriteReg) begin
		if (HWriteReg) begin
			case(SIGNAL_LENGTH)
				4'b0001: begin
					for (int j = 0; j < 8; j = j + 1) begin: assign_8_bits_data
						PWDATA[j] = mid_pwdata[j];				// return only 8 bits of original data
					end
					for (int k = 8; k < 32; k = k + 1) begin: assign_24_bits_reverse
						PWDATA[k] = 1'b1;							// return data as reverse 24 bits 1
					end
				end
				4'b0010: begin
					for (int j = 0; j < 16; j = j + 1) begin: assign_16_bits_data
						PWDATA[j] = mid_pwdata[j];				// return only 16 bits of original data
					end
					for (int k = 16; k < 32; k = k + 1) begin: assign_16_bits_reverse
						PWDATA[k] = 1'b1;							// return data as reverse 16 bits 1
					end
				end
				4'b0100: begin
					for (int j = 0; j < 32; j = j + 1) begin: assign_32_bits_data
						PWDATA[j] = mid_pwdata[j];				// return fully 32 bits of original data
					end
				end
				default: begin										// during this step original program operation only validate between 8-32 bits length only
					for (int j = 0; j < 8; j = j + 1) begin: assign_8_bits_data_default
						PWDATA[j] = mid_pwdata[j];				// return only 8 bits of original data
					end
					for (int k = 8; k < 32; k = k + 1) begin: assign_24_bits_reverse_default
						PWDATA[k] = 1'b1;							// return data as reverse
					end
				end
			endcase
		end
		else
			for (int j = 0; j < 32; j = j + 1) begin: assign_32_bits_zeros
				PWDATA[j] = PWDATA[j];				// return fully 32 bits of original data
			end
	end

endmodule
