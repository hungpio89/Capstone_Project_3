module fifo_read_memory 
#(	// Parameters
	parameter int ADDRBIT 	 = 5,
	parameter int DATA_WIDTH = 12,
	parameter int FIFO_DEPTH = 32
)
(
	input  logic							clk,         	// Clock signal
	input  logic							rst_n,       	// Active-low reset
	input  logic							write_en,    	// Write enable (push data)
	input  logic							read_en,     	// Read enable (pop data)
	input  logic [ DATA_WIDTH-1:  0]	write_data,  	// Data to write into the FIFO
	input  logic [ 	ADDRBIT-1:  0]	wraddr,  		// Address to write into the FIFO
	input  logic [ 	ADDRBIT-1:  0]	rdaddr,  	 	// Address to read from the FIFO
	input  logic							fifofull,      // High when FIFO is fifofull
	input  logic							notempty,		// High when FIFO is empty
	input  logic							fifo_en,
	
	output logic [ DATA_WIDTH-1:  0]	read_data   	// Data read from the FIFO
);
	
	// Memory array and pointers
	reg 	[ DATA_WIDTH-1:  0]	memory [0:FIFO_DEPTH-1];  // Memory array for FIFO
	reg   [ 	  ADDRBIT-1:  0]	write_ptr, read_ptr;      // Write and read pointers
	reg	[ DATA_WIDTH-1:  0]	temp_read;
	
	assign write_ptr = wraddr;
	assign read_ptr  = rdaddr;
	
	// Write and Read operations
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			// Reset data have stored
			for (int i = 0; i < 32; i = i + 1) begin: assign_zeros_to_all_reg
				memory[i] <= 12'h0;
			end
		end 
		else begin
			if (fifo_en) begin
				// Write operation (push to FIFO)
				if (write_en && !fifofull) begin
					memory[write_ptr] <= write_data;
				end
				else begin
					// Read operation (pop from FIFO)
					if (read_en && notempty) begin
						temp_read <= memory[read_ptr];
					end
					else
						temp_read	<= temp_read;
				end
			end
			else
				temp_read <= write_data;
		end
	end
	
	assign read_data = temp_read;
	
endmodule
