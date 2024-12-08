module or_1bit	(
// Input and Output 
	// Input Logic
	input logic						data_in1,
	input logic						data_in2,
	
	// Output logic 
	output logic 					data_out
);
	
	assign 		data_out = data_in1 | data_in2;

endmodule	