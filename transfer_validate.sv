module transfer_validate 					// define for availabe to UART block
(
	// INPUT LOGIC ASSIGNMENT
	input logic [   3 :   0] 	PADDR,  // 4-bits input
	input logic 					PSEL,
	 
	// OUTPUT LOGIC ASSIGNMENT
	output logic       			transfer  // Data valid flag output
);

	// Assuming the data is valid when all inputs are non-zero
	always @(PADDR, PSEL) begin
		if (PADDR == 4'h4 && PSEL) begin
			transfer = 1'b1; // Data is valid in case of 4 MSB is satisfied index address
		end 
		else begin
			transfer = 1'b0; // Data is not valid
		end
	end

endmodule
