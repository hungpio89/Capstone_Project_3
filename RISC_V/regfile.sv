module regfile
(
  input  logic [ 4 : 0]     rs1_addr, rs2_addr,rd_addr,		// input rs1_addr, rs2_addr
  input  logic              rd_wren, clk_i, rst_ni,
  input  logic [31 : 0]     rd_data,                 		// the write data for rd
  output reg   [31 : 0]     rs1_data, rs2_data 	 		// the write data for rs1 and rs2
);

  reg [31:0] mem [0:31];    
//initial begin
//	$writememh("/home/andrea/milestone3/src/reg.txt", mem); 
//end

// Read the vaule in the reg if there is the input reg address
//      assign  rs1_data = temp [rs1_addr];
//      assign  rs2_data = temp [rs2_addr];
/* verilator lint_off LATCH */
always_comb begin
// Write the vaule into the register with given register destination address               
	// Read the vaule in the reg if there is the input reg address
        		 rs1_data = mem [rs1_addr];
        		 rs2_data = mem [rs2_addr];
end
/* verilator lint_off LATCH */

always_ff @(posedge clk_i, negedge rst_ni) begin
// If reset signal is active, reset all registers
	if (!rst_ni) begin           
		for (integer j = 0; j < 32; j = j + 1)
			mem[j] 	<= 32'b0;
	end

	else if (rd_wren)	begin //rd_wren = 1   // Write the data
                if (rd_addr != 0)                               // Ignore writing into the register 0
			mem [rd_addr]  <= rd_data;
                else
                        mem [rd_addr]  <= 32'b0;               // register 0 has always to be 0
        end
	//$writememh("reg.txt", mem);
end
endmodule
