module xor_32bit	(
// Input and Output 
	// Input Logic
	input 		[31 : 0]		data_in1,
	input 		[31 : 0]		data_in2,
	
	// Output logic 
	output		[31 : 0]		data_out
);

genvar i;
generate
	for (i = 0; i < 32; i = i + 1) begin: xor32_generate
		assign		data_out[i] = data_in1[i] ^ data_in2[i];
	end
endgenerate

endmodule
