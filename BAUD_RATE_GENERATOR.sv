module BAUD_RATE_GENERATOR 
(
	// INPUT LOGIC CONFIGURATION
	
	//------------------CPU INPUT------------------------//
	input  logic 				uart_ref_clk,        			// Input clock (custom)
	input  logic 				rst_n,           					// Reset signal
	input  logic 				uart_mode_sel,
	//---------------------------------------------------//
	//---------------INPUT FROM APB INTERFACE------------//
	input  logic 				baud_div_16,
	input  logic [ 12 :  0] cd,
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------BAUD GEN OUT-------------------//
	output logic 				baud_tick,         				// Output clock (baud rate clock)
	//---------------------------------------------------//
	
	// Delete later
	output 	reg 			[ 12 :  0] 	counter_baud,       	// Counter to divide the clock
	output 	reg			[ 12 :  0] 	cd_count
);

//	reg 			[ 12 :  0] 	counter_baud;       	// Counter to divide the clock
//	reg			[ 12 :  0] 	cd_count;
	logic 			  			clk_sel;
	logic 						is_equal;
	
	assign cd_count = cd - 13'd1;
	
	logic [31:0] counter;        // Counter for dividing the clock

    always_ff @(posedge baud_div_16 or negedge rst_n) begin
        if (!rst_n)
            counter <= 32'b0;    // Reset counter
        else if (counter == cd_count) // If counter reaches divisor-1
            counter <= 32'b0;    // Reset counter
        else
            counter <= counter + 1; // Increment counter
    end

    // Toggle clk_out when counter reaches divisor/2
    always_ff @(posedge baud_div_16 or negedge rst_n) begin
        if (!rst_n)
            clk_sel <= 1'b0; // Reset clk_out
        else if (counter == cd_count)
            clk_sel <= ~clk_sel; // Toggle clk_out
    end
	
	always_comb begin
		case(uart_mode_sel)
			1'b0: begin
				baud_tick 		= clk_sel;
			end
			1'b1: begin 
				baud_tick 		= uart_ref_clk;
			end
		endcase
	end
	
endmodule
