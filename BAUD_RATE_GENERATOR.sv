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
	assign is_equal = &(~(cd_count ^ counter_baud));
	
	always_ff @(posedge baud_div_16 or negedge rst_n) begin
		if (!rst_n) begin
			counter_baud 		= 13'd0;
			clk_sel 		 		= 1'b0;
		end 
		else begin
			case (uart_mode_sel)
				1'b0: begin
					if (is_equal) begin
						counter_baud 	= 13'd0;
						clk_sel 			= ~clk_sel;  // Toggle the output clock
					end 
					else begin
						counter_baud 	= counter_baud + 13'b0_0000_0000_0001;
						clk_sel 			= clk_sel;
					end
				end
				1'b1: begin
					counter_baud 	= 13'd0;
				end
			endcase
		end
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
