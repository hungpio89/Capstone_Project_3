module imem (
  input  logic  [31:0] 	addr,
  input logic 	 	rst_ni,
  output reg    [31:0] 	inst
);

  reg   [31 : 0]		mem [0 : 2047];
  reg   [1 : 0]         pbyte;
  reg   [10 : 0]        pword;

  assign        pbyte  = addr[1 : 0];
  assign        pword  = addr[12 : 2];

  initial begin
    $readmemh("imem_data.txt", mem);

  end
/* verilator lint_off LATCH */
always @(addr, pbyte, pword, rst_ni) begin
	if (!rst_ni) 
		inst = 0;
	
        else if (rst_ni & (pbyte == 2'b00))
                inst = mem[pword];
end
/* verilator lint_off LATCH */
endmodule
