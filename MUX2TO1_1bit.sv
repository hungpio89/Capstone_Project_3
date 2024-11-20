module MUX2TO1_1bit
(
	input  logic 		 DIN	[ 0 : 1],
	input  logic 		 SEL,
	output logic  		 DOUT
);
	always @(SEL) begin
		DOUT = 0;
		case(SEL)
			1: DOUT = DIN[1];
			0: DOUT = DIN[0];
		endcase
	end
endmodule
