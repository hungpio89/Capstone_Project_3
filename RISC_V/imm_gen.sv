module imm_gen
(
	input  logic [ 4:0] immsel,
	input  logic [31:7] inst,
	output logic [31:0] imm
);
	logic w1; 
	logic [9:0] inst_i;
// assign bit[11] of imm for I, S, B, J and U type
MUX2TO1_1BIT Comp1
(
	.imm_in1(inst	[ 31]),
	.imm_in2(inst  [ 31]),
	.imm_in3(inst	[  7]),
	.imm_in4(inst  [ 20]),
	.imm_in5(		 1'b0),
	.immsel (immsel[4:0]),
	.imm    (	  w1)
);

assign inst_i = {inst[24:20], inst[11: 7]};
// assign bit[4:0] of imm for I, S, B, J and U type
MUX2TO1_5BITLOW Comp2
(
	.inst  (      inst_i),
	.immsel(immsel[ 4:0]),
	.imm   (imm   [ 4:0])
);

	assign imm[11] = w1;
	always @(*) begin
		imm[31:12] = 0;
		imm[10: 5] = 0;
		case(immsel)
			5'b00001: begin											// I type
				for(int i = 31; i >= 12; i = i - 1) begin    
					imm[i]  =          w1;
				end
				imm[10:5]  = inst[30:25];
			end
			5'b00010: begin											// S type
				for(int i = 31; i >= 12; i = i - 1) begin    
					imm[i]  =          w1;
				end
				imm[10:5]  = inst[30:25];
			end
			5'b00100: begin											// B type
				imm[12]    =    inst[31]; 
				for(int j = 31; j >= 13; j = j - 1) begin    
					imm[j]  =     imm[12];
				end
				imm[10:5]  = inst[30:25];
			end
			5'b01000: begin											// J type
				imm[   20] = inst[	 31];
				imm[19:12] = inst[19:12]; 
				imm[10: 5] = inst[30:25];
				for(int k = 31; k >= 21; k = k - 1) begin    
					imm[k]  =          0;
				end
			end
			5'b10000: begin											// U type
				imm[31:12] = inst[31:12];
				imm[10: 5] =           0;
			end
			default: begin 
				imm[31:12] = 0;
				imm[10: 5] = 0;
			end
		endcase
	end
endmodule
