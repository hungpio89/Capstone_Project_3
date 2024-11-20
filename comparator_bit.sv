module comparator_bit
(
	input logic [ 3 :  0] bit_used,
	input logic [ 3 :  0] count_value_i,
	
	output reg 			 	 done
);
	
	logic [ 3 : 0] comparator_val;
	
	always @(bit_used) begin
		case (bit_used)
			4'd9		: comparator_val <= 4'd11;				// parity: 1bit + data: 8bit
			4'd8		: comparator_val <= 4'd10;				// data:   8bit
			default	: comparator_val <= 4'd0;
		endcase
	end
	
	always @(count_value_i, comparator_val) begin
		if (count_value_i == comparator_val) begin
			done <= 1'b1;
		end
		else
			done <= 1'b0;
	end

endmodule
