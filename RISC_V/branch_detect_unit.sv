module branch_detect_unit (
// Signal for branch and jump detect
input logic			MEM_brj_en,

// Output enable and reset for IF/ID, ID/EX and EX/MEM stage
output logic		IF_rst_n,	
output logic		ID_rst_n
);

always @(*) begin	
	if (MEM_brj_en) begin
		IF_rst_n			= 0;	
		ID_rst_n			= 0;
	end
	
	else begin
		IF_rst_n			= 1;	
		ID_rst_n			= 1;
	end
end
endmodule
