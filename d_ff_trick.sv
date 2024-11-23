module d_ff_trick (
	input logic clk,               // Clock signal
	input logic reset_n,           // Active-low asynchronous reset
	input logic d,                 // Data input
	input logic [4:0] en,          // 5-bit enable signal
	output logic	is_diff,
	output logic q                 // Output
);
//	logic 		is_diff;
	logic [4:0] prev_en;           // Internal signal to store previous en value
	
	assign is_diff = prev_en ^ en;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			q 			<= 1'b0;             // Reset output to 0
			prev_en 	<= 5'b0;       // Reset internal prev_en to 0
		end 
		else begin
			if (is_diff) begin
				q 		  <= d;            // Update output if all bits of en are high
				prev_en <= en;         // Store the current en value
			end
			else
				q 		  <= q;            // Update output if all bits of en are high
				prev_en <= prev_en;
		end
	end

endmodule
