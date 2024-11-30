module shift_left_32bit	(
// Input and Output 
	// Input Logic
	input logic		[31 : 0]		in,
	input logic		[31 : 0]		shift_sel,
	
	// Output logic 
	output logic 	[31 : 0]		out
);

// if the shift _sel signal have the value over 32, that mean the out signal value is always 0.
// So we just only use 5 first bit of the shift _sel signal
// Local declaration 
	logic 			[31 : 0]		shift_1;
	logic 			[31 : 0]		shift_2;
	logic 			[31 : 0]		shift_4;
	logic 			[31 : 0]		shift_8;
	logic 			[31 : 0]		shift_16;

	
	logic 			[31 : 0]		shift1_out, shift2_out, shift4_out, shift8_out, shift16_out;
	
	assign			shift_1	= {in[30 : 0]		,  1'b0};
	assign			shift_2	= {shift1_out[29 : 0],  2'b0};
	assign			shift_4	= {shift2_out[27 : 0],  4'b0};
	assign			shift_8	= {shift4_out[23 : 0],  8'b0};
	assign			shift_16	= {shift8_out[15 : 0], 16'b0};
	
	assign			out		= shift16_out;

	 wire _unused_ok = &{1'b0, shift_sel[31 : 5], 1'b0};
// Structure in the module
mux2to1_32bit		shift1_inst		(
	// Input
						.a	(in),
						.b	(shift_1),
						.sel	(shift_sel[0]),
	// Output
						.s	(shift1_out)
);

mux2to1_32bit		shift2_inst		(
	// Input
						.a	(shift1_out),
						.b	(shift_2),
						.sel	(shift_sel[1]),
	// Output
						.s	(shift2_out)
);

mux2to1_32bit		shift4_inst		(
	// Input
						.a	(shift2_out),
						.b	(shift_4),
						.sel	(shift_sel[2]),
	// Output
						.s	(shift4_out)
);

mux2to1_32bit		shift8_inst		(
	// Input
						.a	(shift4_out),
						.b	(shift_8),
						.sel	(shift_sel[3]),
	// Output
						.s	(shift8_out)
);

mux2to1_32bit		shift16_inst		(
	// Input
						.a	(shift8_out),
						.b	(shift_16),
						.sel	(shift_sel[4]),
	// Output
						.s	(shift16_out)
);

endmodule

