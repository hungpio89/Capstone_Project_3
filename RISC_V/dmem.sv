module dmem
(
  input  logic 		clk_i,
  input  logic 		rst_ni,
  input  logic [31: 0]  addr,		// addr[11] = addr_i[5], addr[8:4] = addr_i[4:0]
  input  logic [31: 0]  st_data,
  input  logic [31: 0]  io_sw,

  input logic            st_en,
  input logic            sb_en,
  input logic            sh_en,
  input logic            sw_en,

  input logic            lb_en,
  input logic            lh_en,
  input logic            lbu_en,
  input logic            lhu_en,
  input logic            lw_en,

  output logic [31: 0]  ld_data,
  output logic [31: 0]  io_lcd,
  output logic [31: 0]  io_ledg,
  output logic [31: 0]  io_ledr,
  output logic [31: 0]  io_hex0,
  output logic [31: 0]  io_hex1,
  output logic [31: 0]  io_hex2,
  output logic [31: 0]  io_hex3,
  output logic [31: 0]  io_hex4,
  output logic [31: 0]  io_hex5,
  output logic [31: 0]  io_hex6,
  output logic [31: 0]  io_hex7
);

	
	//-------------------
	// Input_Periph  0x900           <=>                        12'b1001_0000_0000 (SW)
	// Output_Periph 0x800 --> 0x8FF <=> 12'b1000_0000_0000 --> 12'b1000_1111_1111
	// Data_Memory   0x000 --> 0x7FF <=> 12'b0000_0000_0000 --> 12'b0111_1111_1111
	//-------------------

//-------------------create signal--------------------
		logic [1:0] addr_sel;
		
		logic [31: 0] st_data_mem, ld_data_mem;
		
		reg 	[7 : 0]	data_mem				[0 : 127];	// 0x000 to 0x7FF
		//logic [7 : 0]	data_mem_temp		[0 : 2047];	// 0x000 to 0x7FF
		
		reg 	[7 : 0]	data_output			[0 :  43];	// 0x800 to 0x8FF with 11 output peripherals 32 bit
		//logic [7 : 0]	data_output_temp	[0 :  43];	// 0x000 to 0x7FF
		
		reg 	[7 : 0]	data_input			[0 :  3];	// 0x900 to 0x9FF
		
		logic [7 : 0]	temp_st				[0 : 3];
		logic [7 : 0]	temp_ld				[0 : 3];
	//----------------------------------------------------

	//-------------------assign port--------------------
load_inst LOAD_DAT(
	.load_data			(ld_data_mem),
	.lb_en				(lb_en), 
	.lh_en				(lh_en),
	.lw_en				(lw_en),
	.lhu_en				(lhu_en),
	.lbu_en				(lbu_en),
	.output_data		(ld_data)
);

store_inst STORE_DAT(
	.store_data			(st_data),
	.sb_en				(sb_en),
	.sh_en				(sh_en),
	.sw_en            (sw_en),
	.output_data		(st_data_mem)
);

assign addr_sel 		= {addr[11],addr[8]};
//assign data_mem 		= data_mem_temp;
//assign data_output 	= data_output_temp;
	//----------------------------------------------------
// Input load data 32bit ld_data_mem
genvar i;
generate 
	for (i = 0; i < 4; i = i + 1)	begin: generate_load_store
		assign	temp_st [i] 						= st_data_mem [7 + i*8 : i*8];
		assign	ld_data_mem [7 + i*8 : i*8]	= temp_ld [i];
		assign   data_input [i]						= io_sw [7 + i*8 : i*8];
	end
endgenerate
/* verilator lint_off BLKSEQ */
//always @(posedge clk_i, negedge rst_ni)	begin
//	if (!rst_ni) begin
//		integer h,j;
//		for (h = 0; h < 2048; h = h + 1) begin
//			data_mem[h] = 8'b0;
//		end
//
//		for (j = 0; j < 44; j = j + 1) begin
//			data_output[j] = 8'b0;
//		end
//	end
//end 

/* verilator lint_off LATCH */
//always @(st_en, addr, addr_sel) begin
always_ff @(posedge clk_i, negedge rst_ni) begin 
	if (!rst_ni) begin
		integer h,j;
		for (h = 0; h < 127; h = h + 1) begin
			data_mem[h] = 8'b0;
		end

		for (j = 0; j < 44; j = j + 1) begin
			data_output[j] = 8'b0;
		end
	end
	
	else if (st_en)	 begin					// Store Operation
		case (addr_sel)
			2'b00, 2'b01: begin		// Data
				for (int k = 0; k < 4; k = k + 1) begin
					data_mem [addr + k] 	<= temp_st [k];
				end
			end
				
			2'b10: begin				//Output
				for (int k = 0; k < 4; k = k + 1) begin
					case (addr)
						32'h800: begin
							data_output[k] <= temp_st [k];
						end
						
						32'h810: begin
							data_output[k + 4] <= temp_st [k];
						end
							
						32'h820: begin
							data_output[k + 8] <= temp_st [k];
						end
							
						32'h830: begin
							data_output[k + 12] <= temp_st [k];
						end
							
						32'h840: begin
							data_output[k + 16] <= temp_st [k];
						end
							
						32'h850: begin
							data_output[k + 20] <= temp_st [k];
						end
							
						32'h860: begin
							data_output[k + 24] <= temp_st [k];
						end
							
						32'h870: begin
							data_output[k + 28] <= temp_st [k];
						end
							
						32'h880: begin
							data_output[k + 32] <= temp_st [k];
						end
							
						32'h890: begin
							data_output[k + 36] <= temp_st [k];
						end
							
						32'h8A0: begin
							data_output[k + 40] <= temp_st [k];
						end
							
						default: begin
							data_output[k] 	<= temp_st [k];			// Store default into the begin of the output peripherals
						end
					endcase
				end
			end
				
			default: begin	
				for (int k = 0; k < 4; k = k + 1) begin
					data_mem[addr + k] 		<= temp_st [k];			// Store default into the begin of the output peripherals
				end
			end
		endcase
	end
end
				
//			2'b01: begin		// Data
//				for (integer k = 0; k < 4; k = k + 1) begin
//					 data_mem [addr + k] <= temp_st [k];
//				end
//			end
	
always_comb begin
	if (!st_en) begin			// Load
		case (addr_sel)
			2'b00, 2'b01: begin		// Data
				for (int k = 0; k < 4; k = k + 1) begin
					temp_ld [k] = data_mem [addr + k];
				end
			end

			2'b10: begin		// Output 
				for (int k = 0; k < 4; k = k + 1) begin
					case (addr)
						32'h800: begin
								temp_ld[k] = data_output[k];
						end
						
						32'h810: begin
								temp_ld[k] = data_output[k + 4];
						end
						
						32'h820: begin
								temp_ld[k] = data_output[k + 8];
						end
						
						32'h830: begin
								temp_ld[k] = data_output[k + 12];
						end
						
						32'h840: begin
								temp_ld[k] = data_output[k + 16];
						end
						
						32'h850: begin
								temp_ld[k] = data_output[k + 20];
						end
						
						32'h860: begin
								temp_ld[k] = data_output[k + 24];
						end
						
						32'h870: begin
								temp_ld[k] = data_output[k + 28];
						end
						
						32'h880: begin
								temp_ld[k] = data_output[k + 32];
						end
						
						32'h890: begin
								temp_ld[k] = data_output[k + 36];
						end
						
						32'h8A0: begin
								temp_ld[k]= data_output[k + 40];
						end
						
						default: begin
								temp_ld [k] = data_output[k];
						end
					endcase
				end
			end
		
			
			2'b11: begin		// Input 
				for (int k = 0; k < 4; k = k + 1) begin
					 temp_ld [k] = data_input [k];
				end
			end

			default: begin		// Save in datamem
				for (int k = 0; k < 4; k = k + 1) begin
					 temp_ld [k] = data_output[k];				// load default into the begin of the output peripherals
				end
			end	
		endcase
	end
end

	localparam      HEX0_ADR 			= 0;			// 0x800 => 0
	localparam      HEX1_ADR 			= 4; 			// 0x810	=> 4
	localparam      HEX2_ADR  			= 8;			// 0x820	=> 8
	localparam      HEX3_ADR  			= 12;			// 0x830	=> 12
	localparam      HEX4_ADR  			= 16;			// 0x840	=> 16
	localparam      HEX5_ADR  			= 20;			// 0x850	=> 20
	localparam      HEX6_ADR  			= 24;			// 0x860	=> 24
	localparam      HEX7_ADR  			= 28;			// 0x870	=> 28
	localparam      LEDR      			= 32;			// 0x880	=> 32
	localparam      LEDG      			= 36;			// 0x890	=> 36
	localparam      LCD       			= 40;			// 0x8A0	=> 40
	
	genvar l;
	generate
		for (l = 0; l < 4; l = l + 1) begin: assign_data_output
			assign	io_lcd [7 + l*8 : l*8] = data_output[LCD + l];
			assign  io_hex0 [7 + l*8 : l*8] = data_output[HEX0_ADR + l];
			assign  io_hex1 [7 + l*8 : l*8] = data_output[HEX1_ADR + l];
			assign  io_hex2 [7 + l*8 : l*8] = data_output[HEX2_ADR + l];
			assign  io_hex3 [7 + l*8 : l*8] = data_output[HEX3_ADR + l];
			assign  io_hex4 [7 + l*8 : l*8] = data_output[HEX4_ADR + l];
			assign  io_hex5 [7 + l*8 : l*8] = data_output[HEX5_ADR + l];
			assign  io_hex6 [7 + l*8 : l*8] = data_output[HEX6_ADR + l];
			assign  io_hex7 [7 + l*8 : l*8] = data_output[HEX7_ADR + l];
			assign  io_ledr [7 + l*8 : l*8] = data_output[LEDR + l];
			assign  io_ledg [7 + l*8 : l*8] = data_output[LEDG + l];
		end
	endgenerate
endmodule
