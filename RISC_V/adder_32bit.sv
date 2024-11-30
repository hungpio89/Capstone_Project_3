/* verilator lint_off UNOPTFLAT */
module adder_32bit (
// Input and Output 
	// Input Logic
	input logic	[31 : 0]		a,
	input logic 	[31 : 0]		b,
	input logic				cin,
	
	// Output logic 
	output logic 	[31 : 0]		s
	//output logic 				cout
);

// Local declaration 
	wire		[31 : 0]	c;
	
	assign 		c[0]  		= cin;

// Combine 32 full adder 1 bit to create a 32 bit fulladder
genvar i;
generate
	for (i = 0; i < 31; i = i + 1)	begin: gen_fulladder32_low
		fulladder_1bit		fulladder_inst_0	(
		// Input Logic
					.a				(a[i]),
					.b				(b[i]),
					.cin				(c[i]),
	
		// Output logic 
					.s				(s[i]),
					.cout				(c[i + 1])
		);
	end
endgenerate

adder_1bit				adder_inst	(
		// Input Logic
                                        .a                              (a[31]),
                                        .b                              (b[31]),
                                        .cin                            (c[31]),

                // Output logic
                                        .s                              (s[31])
);
	//assign cout = c[32];
endmodule
