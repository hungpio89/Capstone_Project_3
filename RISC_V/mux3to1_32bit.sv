module mux3to1_32bit (
// Input and output 
	input logic 	[31 : 0]		a0,
	input logic 	[31 : 0]		a1,
	input logic 	[31 : 0]		a2,
	input logic		[ 1 : 0]		sel,
	
	output logic	[31 : 0]		s
);

always_comb begin
	case(sel)
		2'b00:	s = a0;
		2'b01:	s = a1;
		2'b10:	s = a2;
		default: s = 0;
	endcase
end
endmodule
