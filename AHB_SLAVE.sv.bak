module AHB_SLAVE // BRIDGE MODULE (AHB TO APB)
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic 					HCLK,						// input clk_i from CPU (interface with rising-edge).
	input logic 					HRESETn,					// input rst_ni from CPU.
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  1 :  0]	HTRANS,					// This indicates the type of the current transfer, which can be NONSEQUENTIAL, SEQUENTIAL, IDLE or BUSY.
	input logic		[  2 :  0]	HSIZES,
	input logic		[  2 :  0]	HBURST,
	input logic 					HWRITE,					// indicates an AHB write ACCESS when HIGH (1) and an AHB read ACCESS when LOW (0).
//	
//																	// indicates that the current transfer is intended for the selected.
//																	// slave. This signal is a combinatorial decode of the address bus.	
	input logic 					HREADYin,				// When HIGH the HREADY signal indicates that a transfer has
																	// finished on the bus. This signal may be driven LOW to extend a transfer.
	input logic		[ 31 :  0]	HWDATA,
	input logic		[ 31 :  0]	HADDR,					// The 32-bit system address bus.
	input logic		[ 31 :  0]	PRDATA,
	input logic						PREADY,
	//---------------------------------------------------//
	//---------------------------------------------------//
	
	// OUTPUT LOGIC CONFIGURATION
	
	//--------------------REQUESTER OUT------------------//
	// SEND TO SLAVE
	output logic	[ 31 :  0]	PWDATA,
	output logic	[ 31 :  0]	PADDR,
	output logic 					PENABLE,					// indicates second and subsequent cycles of an APB transfer.
	output logic 					PWRITE,					// indicates an APB write ACCESS when HIGH (1) and an APB read ACCESS when LOW (0).
	output logic 					HREADYout,
	output logic 	[  1 :  0]	HRESP,
	output logic 					PSELx,
	
	// SEND BACK TO MASTER
	output logic	[ 31 :  0]	HRDATA
	//---------------------------------------------------//
);

	//	Local Signal declaration for communication
	logic								HSELABPif;				// Each APB slave has its own slave select signal, and this signal.
	logic								PWRITE_Int;
	logic								PENABLE_int;
	logic								PSELx_mid;
	logic								PSELxInt, Valid, APBen;
	
	// Local Register declaration for Storing Interface's Signal
	reg								HwriteReg;
	reg				[  5 :  0]	AHBI_DataLength_ldB6;

	typedef enum bit[ 1 : 0] {IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11} hstate;
	
	typedef enum bit[ 2 : 0] {SINGLE = 3'b000, INCR = 3'b001, WRAP4 = 3'b010, INCR4 = 3'b011, WRAP8 = 3'b100, INCR8 = 3'b101, WRAP16 = 3'b110, INCR16 = 3'b111} Type;		// this is used for HBURST
	
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			HSELABPif <= 1'b0;
			HRESP 	 <= 2'b00;
		end
		else begin
			if (HADDR >= 32'h8000_0000 && HADDR < 32'h8C00_0000) begin
				HSELABPif <= 1'b1;
				HRESP 	 <= 2'b01;
			end
			else begin
				HSELABPif <= 1'b0;
				HRESP 	 <= 2'b00;
			end
		end
	end
	
	//-------------------HTRANS ASSIGNMENT---------------------//
	hstate HST_TRANS;				// HST: HSTATE of HTRANS
	always @(HTRANS) begin
		case (HTRANS) 
			2'd0: begin
				HST_TRANS = IDLE;
			end
			2'd1: begin
				HST_TRANS = BUSY;
			end
			2'd2: begin
				HST_TRANS = NONSEQ;
			end
			2'd3: begin
				HST_TRANS = SEQ;
			end
		endcase
	end
	//---------------------------------------------------------//
	
	always @(HREADYin, HST_TRANS, HSELABPif) begin
		//------------------Valid logic--------------------
		if (HREADYin && HSELABPif && (HST_TRANS == SEQ || HST_TRANS == NONSEQ)) begin
			Valid <= 1'b1;
		end
		else begin
			Valid <= 1'b0;
		end
	end

FSM_AHB								State_machine // Advanced High Performance Bus
(
				// INPUT LOGIC ASSIGNMENT
				.HCLK					(HCLK),						
				.HRESETn				(HRESETn),					
				.Valid				(Valid),
				.HWRITE				(HWRITE),
				.PREADY				(PREADY),
				
				// OUTPUT LOGIC CONFIGURATION
				.HwriteReg			(HwriteReg),
				.HREADYout			(HREADYout),
				.APBen				(APBen),
				.PENABLE				(PENABLE_int),
				.PSELx				(PSELxInt),
				.PWRITE				(PWRITE_Int)
	
);

EncoderDataLength 				ENCODER_DATA_LENGTH_BLOCK								// Internal module to give out the number of data used (AHB master TO AHB Bridge)
(
				// INPUT LOGIC ASSIGNMENT
				.HSIZES				(HSIZES),

				// OUTPUT LOGIC CONFIGURATION
				.SIGNAL_LENGTH		(AHBI_DataLength_ldB6)
);

register_enable_only				RDATA_BLOCK
(	
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_n 				(HRESETn),
				.enable				(PWRITE_Int),
	
				// OUTPUT LOGIC ASSIGNMENT
				.D						(PRDATA),
				.Q						(HRDATA)
);

D_FF_1bit							D_FF_PENABLE
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.D						(PENABLE_int),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PENABLE)
);

D_FF_1bit_with_Sel				D_FF_PWRITE
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.enable				(APBen),
				.D						(PWRITE_Int),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PWRITE)
);

D_FF_32bit_with_Sel				D_FF_PADDR
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.enable				(APBen),
				.D						(HADDR),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PADDR)
);

address_decode				  		Address_decode
(
				// INPUT LOGIC ASSIGNMENT
				.HADDR				(HADDR),
				.PSEL_sel			(PSELxInt),
				
				// OUTPUT LOGIC ASSIGNMENT
				.PSEL_en				(PSELx_mid)
);

D_FF_1bit_with_Sel				D_FF_PSELX
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.enable				(1'b1),
				.D						(PSELx_mid),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PSELx)
);

DataLengthDecoder 				D_FF_PWDATA							// This block is an customize module only used for interupt data length
(
				// INPUT LOGIC ASSIGNMENT
				.HCLK					(HCLK),
				.HRESETn				(HRESETn),
				.HWriteReg			(HwriteReg),
				.HWDATA				(HWDATA),
				.SIGNAL_LENGTH		(AHBI_DataLength_ldB6),
	
				// OUTPUT LOGIC CONFIGURATION
				.PWDATA				(PWDATA)
);
endmodule
