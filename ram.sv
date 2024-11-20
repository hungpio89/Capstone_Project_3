module ram #(
	parameter ADDR_WIDTH 		= 10,										// 2^10 addresses, equivalent to 1KB RAM
	parameter DATA_WIDTH 		= 32,             					// 32-bit data width
	parameter DATA_MEM_WIDTH 	= 8
)(
	// INPUT LOGIC ASSIGNMENT
	
	//-----------------INPUT FROM MASTER-----------------//
	input		logic                  HCLK,     				// AHB clock
	input 	logic                  HRESETn,  				// AHB active-low reset
	input 	logic [ADDR_WIDTH-1:0] HADDR,    				// Address from AHB
	input 	logic                  HWRITE,   				// Write control signal
	input 	logic [1:0]            HTRANS,   				// Transfer type (simple, burst, etc.)
	input 	logic                  HSEL,     				// Select signal for RAM
	input		logic                  HREADY,   				// Ready signal
	input		logic [DATA_WIDTH-1:0] HWDATA,   				// Write data
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------// customize
//	input		loigc	[1:0]				  op_mode,					// indicate the mode operation of RAM (MASTER SLAVE, MASTER ONLY, SLAVE ONLY)
																			// op_mode[1]: master, op_mode[0]: slave
	//---------------------------------------------------//
	
	// OUTPUT LOGIC ASSIGNMENT
	
	//-----------------OUTPUT TO MASTER------------------//
	output	reg 	[DATA_WIDTH-1:0] HRDATA,   				// Read data
	output 	reg                    HREADYOUT 				// Ready output signal
	//---------------------------------------------------//
	
	// Delete later
	
);

	// RAM storage
	reg [DATA_MEM_WIDTH-1:0] mem [(1 << (ADDR_WIDTH-1)) - 1:0];				// 512 address

	// Internal signal to store address phase
	reg [ADDR_WIDTH-1:0] addr_reg;

	// HREADYOUT control logic
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			HREADYOUT <= 1'b1;
		end 
		else begin
			HREADYOUT <= HSEL && HTRANS[1];
		end
	end

	// Write operation
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			for (int i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin: clear_all_mem
				mem[i] <= 8'b0;
			end
		end
		else begin
//			case (op_mode)
//				2'b11: begin
					if (HWRITE && HSEL && HTRANS[1]) begin
						mem[HADDR	 ] <= HWDATA[ 7: 0];
						mem[HADDR + 1] <= HWDATA[15: 8];
						mem[HADDR + 2] <= HWDATA[23:16];
						mem[HADDR + 3] <= HWDATA[31:24];
					end
//				2'b10: 
//			endcase
		end
	end

	// Read operation
	always @(HSEL, HTRANS, HWRITE) begin
		if (HSEL && HTRANS[1] && !HWRITE) begin
			HRDATA[ 7: 0] <= mem[HADDR	 	];
			HRDATA[15: 8] <= mem[HADDR + 1];
			HRDATA[23:16] <= mem[HADDR + 2];
			HRDATA[31:24] <= mem[HADDR + 3];
		end
		else
			HRDATA		  <= 32'bZ;
	end

endmodule
