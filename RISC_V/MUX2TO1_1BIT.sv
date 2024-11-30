module MUX2TO1_1BIT
(
	input  logic 		 imm_in1,imm_in2,imm_in3,imm_in4,imm_in5,
	input  logic [4:0] immsel,
	output logic  		 imm
);
	always @(*) begin
		imm = 0;
		case(immsel)
			5'b00001: imm = imm_in1;
			5'b00010: imm = imm_in2;
			5'b00100: imm = imm_in3;
			5'b01000: imm = imm_in4;
			5'b10000: imm = imm_in5;
			default : imm =       0;
		endcase
	end
endmodule
