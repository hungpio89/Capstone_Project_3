module fulladder_1bit (
// Input and Output
        // Input Logic
        input logic     a,
        input logic     b,
        input logic     cin,

        // Output logic
        output logic    s,
/* verilator lint_off UNOPTFLAT */
	output logic	cout
);

// Local declaration
        logic           xor1, xor2, and1;
/* verilator lint_off UNOPTFLAT */
// Logic components
        // Xor gates
        assign xor1 = a ^ b;
        assign xor2 = xor1 ^ cin;

        // And gate
        assign and1 = a & b;

        // Sum output
        assign s = xor2;

        // Carry output
        assign cout = (and1 | (a & cin) | (b & cin));

endmodule
