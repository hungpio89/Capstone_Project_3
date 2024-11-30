module inverter_32bit (
// Input and Output 
	// Input Logic
	input logic		[31 : 0]		data_in,
	
	// Output logic 
	output logic 	[31 : 0]		data_out
);

genvar i;
generate
	for (i = 0; i < 32; i = i + 1) begin: inverter32_generate
		assign		data_out[i] = ~data_in[i];
	end
endgenerate

endmodule
