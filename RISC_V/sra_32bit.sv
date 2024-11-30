module sra_32bit	(
// Input and Output 
	// Input Logic
	input logic		[31 : 0]		in,
	input logic		[31 : 0]		shift_sel,
	
	// Output logic 
	output logic 		[31 : 0]		out
);

// if the shift _sel signal have the value over 32, that mean the out signal value is always 0.
// So we just only use 5 first bit of the shift _sel signal
// Local declaration 
	logic 			[31 : 0]		shift_1, shift1_0, shift1_1;
	logic 			[31 : 0]		shift_2, shift2_0, shift2_1;
	logic 			[31 : 0]		shift_4, shift4_0, shift4_1;
	logic 			[31 : 0]		shift_8, shift8_0, shift8_1;
	logic 			[31 : 0]		shift_16, shift16_0, shift16_1;

	
	logic 			[31 : 0]		shift1_out, shift2_out, shift4_out, shift8_out, shift16_out;
	
//	assign			shift_1	= {in[30 : 0]		,  1'b0};
//	assign			shift_2	= {shift1_out[29 : 0],  2'b0};
//	assign			shift_4	= {shift2_out[27 : 0],  4'b0};
//	assign			shift_8	= {shift4_out[23 : 0],  8'b0};
//	assign			shift_16	= {shift8_out[15 : 0], 16'b0};

	assign			shift1_0		= {1'b0	,	in[31 : 1]};
	assign			shift2_0		= {2'b0	,	shift1_out[31 : 2]};
	assign			shift4_0		= {4'b0	,	shift2_out[31 : 4]};
	assign			shift8_0		= {8'b0	,	shift4_out[31 : 8]};
	assign			shift16_0		= {16'b0	,	shift8_out[31 : 16]};
	
	assign			shift1_1		= {1'b1								,	in[31 : 1]};
	assign			shift2_1		= {2'b11								,	shift1_out[31 : 2]};
	assign			shift4_1		= {4'b1111							,	shift2_out[31 : 4]};
	assign			shift8_1		= {8'b1111_1111					,	shift4_out[31 : 8]};
	assign			shift16_1		= {16'b1111_1111_1111_1111		,	shift8_out[31 : 16]};
	
// Result 
	assign			out			= shift16_out;

	  wire _unused_ok = &{1'b0, shift_sel[31 : 5], 1'b0};
	
// Select the extented bit for shift right arithmetic
mux2to1_32bit		select_shift1	(
	// Input
						.a					(shift1_0),
						.b					(shift1_1),
						.sel				(in[31]),
	// Output
						.s					(shift_1)
);

mux2to1_32bit		select_shift2	(
	// Input
						.a					(shift2_0),
						.b					(shift2_1),
						.sel				(in[31]),
	// Output
						.s					(shift_2)
);

mux2to1_32bit		select_shift4	(
	// Input
						.a					(shift4_0),
						.b					(shift4_1),
						.sel				(in[31]),
	// Output
						.s					(shift_4)
);

mux2to1_32bit		select_shift8	(
	// Input
						.a					(shift8_0),
						.b					(shift8_1),
						.sel				(in[31]),
	// Output
						.s					(shift_8)
);

mux2to1_32bit		select_shift16	(
	// Input
						.a					(shift16_0),
						.b					(shift16_1),
						.sel				(in[31]),
	// Output
						.s					(shift_16)
);


// Structure in the module
mux2to1_32bit		shift1_inst		(
	// Input
						.a					(in),
						.b					(shift_1),
						.sel				(shift_sel[0]),
	// Output
						.s					(shift1_out)
);

mux2to1_32bit		shift2_inst		(
	// Input
						.a					(shift1_out),
						.b					(shift_2),
						.sel				(shift_sel[1]),
	// Output
						.s					(shift2_out)
);

mux2to1_32bit		shift4_inst		(
	// Input
						.a					(shift2_out),
						.b					(shift_4),
						.sel				(shift_sel[2]),
	// Output
						.s					(shift4_out)
);

mux2to1_32bit		shift8_inst		(
	// Input
						.a					(shift4_out),
						.b					(shift_8),
						.sel				(shift_sel[3]),
	// Output
						.s					(shift8_out)
);

mux2to1_32bit		shift16_inst		(
	// Input
						.a					(shift8_out),
						.b					(shift_16),
						.sel				(shift_sel[4]),
	// Output
						.s					(shift16_out)
);

endmodule

