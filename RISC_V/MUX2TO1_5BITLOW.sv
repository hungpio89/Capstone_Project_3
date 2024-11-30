module MUX2TO1_5BITLOW
(
	input  logic [ 9: 0] inst,	// inst[24:20] = inst_i[9:5], inst[11:7] = inst_i[4:0]
	input  logic [ 4: 0] immsel,
	output logic [ 4: 0] imm
);

// assign bit[0] of imm for I, S, B, J and B type
MUX2TO1_1BIT IMM0
(
	.imm_in1(inst	[  5]),
	.imm_in2(inst   [  0]),
	.imm_in3(       1'b0 ),
	.imm_in4(       1'b0 ),
	.imm_in5(       1'b0 ),
	.immsel (immsel [4:0]),
	.imm    (imm	[  0])
);
			
	always @(*) begin
		imm[4:1] = 0;
		case(immsel)
			5'b00001: imm[4:1] = inst[ 9: 6];
			5'b01000: imm[4:1] = inst[ 9: 6];
			5'b00010: imm[4:1] = inst[ 4: 1];
			5'b00100: imm[4:1] = inst[ 4: 1];
			5'b10000: imm[4:1] =     4'b0000;
			default : imm[4:1] = 		0;
		endcase
	end
endmodule


