module address_decode 
(
	input logic [ 31 :  0] HADDR, // Input HADDR from AHB
	input logic 			  PSEL_sel,
	
	output logic 			  PSEL_en // Select signal to APB
);	
	logic 					  PSEL_flag;	// this flag is used for checking whether HADDR is or not
    // Logic to set PSEL based on PADDR
	always @(PSEL_sel, HADDR) begin
		PSEL_en = 1'b0;
		if (HADDR != 32'b0) begin
			if (PSEL_sel) begin // Set PSEL to 1 when PADDR is non-zero
				PSEL_en = 1'b1;
			end 
			else begin
				PSEL_en = 1'b0;
			end
		end
	end

endmodule
