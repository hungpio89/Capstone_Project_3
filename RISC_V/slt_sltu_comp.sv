module slt_sltu_comp (
// Input and Output 
	// Input Logic
	input logic	[31 : 0]	rs1,
	input logic 	[31 : 0]	rs2,
	
	// Output logic 
	output logic 	[31 : 0]	data_out_s,
	output logic 	[31 : 0]	data_out_u
);

// Local declaration
	logic 		a, b, c;
	logic 		a_equal_b, a_less_b, a_more_b;
	logic		out_s, out_u;
	assign	a	= 	rs1[31];
	assign	b  	= 	rs2[31];
	assign	c	= 	a_less_b;
	
	 wire _unused_ok = &{1'b0, a_equal_b, a_more_b, 1'b0};
	// slt result
	assign	out_s	= (~b & c) | (a & ~b) |(a & c);
	//stlu result 
	assign	out_u	= a_less_b;
	
// Component
comparator_32bit		comparator_inst 	(
	// Input Logic
				.a				(rs1),
				.b				(rs2),
	
	// Output logic 
				.a_equal_b			(a_equal_b),
				.a_more_b			(a_more_b),
				.a_less_b			(a_less_b)
);

always_comb begin: select_output
	if (out_s & out_u)	begin 
		data_out_s = 32'h0000_0001;
		data_out_u = 32'h0000_0001;
	end 
	else if (!out_s & out_u)	begin
		 data_out_s 	= 32'h0000_0000;
        	 data_out_u 	= 32'h0000_0001;
	end
	else if (out_s & !out_u) begin
                 data_out_s     = 32'h0000_0001;
                 data_out_u     = 32'h0000_0000;
        end
	else begin
                 data_out_s     = 32'h0000_0000;
                 data_out_u     = 32'h0000_0000;
        end
end
endmodule

