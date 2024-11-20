module baud_rate_divisor 
(
    input  logic clk,         	// Input clock at 50 MHz
    input  logic rst_n,          // Reset signal
	 
    output logic clk_out        // Output clock
);

    // A counter to divide the clock
    logic [  3 :   0] counter;        // 4-bit counter (since 2^4 = 16)
//	 logic 		 check_flag;
//	 
//	 assign check_flag = counter[0] & counter [1] & counter [2] & counter[3];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 4'b0;
            clk_out <= 1'b0;
        end 
		  else begin
            if (counter == 4'b1111) begin
                counter <= 4'b0;
                clk_out <= ~clk_out;  // Toggle the output clock
            end 
				else begin
                counter <= counter + 4'b0001;
            end
        end
    end
endmodule
