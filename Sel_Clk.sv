module Sel_Clk
(
	input  logic 	uart_ref_clk,
	input  logic 	clk_div16,
	input  logic 	uart_mode_sel,
	
	output logic  	sel_clk
);
	always @(uart_mode_sel, clk_div16, uart_ref_clk) begin
		case(uart_mode_sel)
			1'b0: sel_clk = uart_ref_clk;
			1'b1: sel_clk = clk_div16;
		endcase
	end
endmodule
