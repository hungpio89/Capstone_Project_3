module AHB_SLAVE // BRIDGE MODULE (AHB TO APB)
(
	// INPUT LOGIC ASSIGNMENT
	
	//------------------CPU INPUT------------------------//
	input logic 					HCLK,						// input clk_i from CPU (interface with rising-edge).
	input logic 					HRESETn,					// input rst_ni from CPU.
	//---------------------------------------------------//
	
	//-----------------INPUT FROM MASTER-----------------//
	input logic		[  1 :  0]	HTRANS,					// This indicates the type of the current transfer, which can be NONSEQUENTIAL, SEQUENTIAL, IDLE or BUSY.
	input logic		[  1 :  0]	HSIZES,
	input logic		[  2 :  0]	HBURST,
	input logic 					HWRITE,					// indicates an AHB write ACCESS when HIGH (1) and an AHB read ACCESS when LOW (0).
//	
//																	// indicates that the current transfer is intended for the selected.
//																	// slave. This signal is a combinatorial decode of the address bus.	
	input logic 					HREADYin,				// When HIGH the HREADY signal indicates that a transfer has
																	// finished on the bus. This signal may be driven LOW to extend a transfer.
	input logic		[ 31 :  0]	HWDATA,
//	input logic		[ 31 :  0]	HADDR,					// The 32-bit system address bus.
	input logic		[ 31 :  0]	PRDATA,
	input logic						PREADY,
	input logic						HSELABPif,				// Each APB slave has its own slave select signal, and this signal.
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
	output logic	[ 31 :  0]	HRDATA,
	output logic	[  2 :  0]	AHB_SLAVE_ERRORS,
	//---------------------------------------------------//
	
	// Delete later
	output logic	[ 31 :  0]	HADDR
);

	//	Local Signal declaration for communication
	logic								PWRITE_Int;
	logic								PENABLE_int;
	logic								PSELxInt;
	logic								Valid;
	logic								VALID_ERROR;
	logic								APBen;
	logic								HADDR_ERROR;
	logic								HTRANS_ERROR;
	
	// Local Register declaration for Storing Interface's Signal
	reg								HwriteReg;
	reg				[  3 :  0]	AHBI_DataLength_ldB4;
	
	// Assignment for Errors signal happen during operation
	// Distribution:
	//						+) index[0]: HADDR_ERROR -> error detect by HADDR exceed the given address available
	//						+) index[1]: HTRANS_ERROR -> error detect by HTRANS is in state IDLE or BUSY
	//						+) index[2]: VALID_ERROR -> error detect by Valid signal whether AHB Bridge is not select or HREADYin is not available or in HTRANS_ERROR
	assign AHB_SLAVE_ERRORS = {VALID_ERROR, HTRANS_ERROR, HADDR_ERROR};

	typedef enum bit[ 1 : 0] {IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11} hstate;
	
	always @(posedge HCLK or negedge HRESETn) begin
		if (!HRESETn) begin
			HRESP 	 		<= 2'b00;
			HADDR_ERROR		<= 1'b0;
		end
		else begin
			if (HADDR >= 32'h8000_0000 && HADDR < 32'h8C00_0000) begin
				HRESP 	 	<= 2'b01;
				HADDR_ERROR	<= 1'b0;
			end
			else begin
				HRESP 	 	<= 2'b00;
				HADDR_ERROR	<= 1'b1;
			end
		end
	end
	
	//-------------------HTRANS ASSIGNMENT---------------------//
	hstate HST_TRANS;				// HST: HSTATE of HTRANS
	always @(HTRANS) begin
		HTRANS_ERROR	= HTRANS_ERROR;
		case (HTRANS) 
			2'd0: begin
				HST_TRANS 		= IDLE;
				HTRANS_ERROR	= 1'b1;
			end
			2'd1: begin
				HST_TRANS 		= BUSY;
				HTRANS_ERROR	= 1'b1;
			end
			2'd2: begin
				HST_TRANS 		= NONSEQ;
				HTRANS_ERROR	= 1'b0;
			end
			2'd3: begin
				HST_TRANS 		= SEQ;
				HTRANS_ERROR	= 1'b0;
			end
		endcase
	end
	//---------------------------------------------------------//
	
	always @(HREADYin, HST_TRANS, HSELABPif) begin
		//------------------Valid logic--------------------
		if (HREADYin && HSELABPif && (HST_TRANS == SEQ || HST_TRANS == NONSEQ)) begin
			Valid 		<= 1'b1;
			VALID_ERROR	<= 1'b0;
		end
		else begin
			Valid 		<= 1'b0;
			VALID_ERROR	<= 1'b1;
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
				.SIGNAL_LENGTH		(AHBI_DataLength_ldB4)
);

register_enable_only				RDATA_BLOCK
(	
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_n 				(HRESETn),
				.enable				(PWRITE_Int),
				.D						(PRDATA),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(HRDATA)
);

D_FF_1bit							D_FF_PENABLE
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.D						(PENABLE_int && APBen),
				
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

encoder_method						ENCODER_METHOD_ADDRESS_BLOCK
(
				// INPUT LOGIC ASSIGNMENT
				.HBURST				(HBURST),
				.HCLK					(HCLK),
				.HRESETn				(HRESETn),
				.enable				(HREADYout),
	
				// OUTPUT LOGIC ASSIGNMENT
				.HADDR				(HADDR)
);

D_FF_32bit_with_Sel				D_FF_PADDR_BLOCK
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.enable				(APBen),
				.D						(HADDR),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PADDR)
);

D_FF_1bit_with_Sel				D_FF_PSELX_BLOCK
(
				// INPUT LOGIC ASSIGNMENT
				.clk					(HCLK), 
				.rst_ni				(HRESETn),
				.enable				(1'b1),
				.D						(PSELxInt),
				
				// OUTPUT LOGIC ASSIGNMENT
				.Q						(PSELx)
);

DataLengthDecoder 				D_FF_PWDATA_BLOCK							// This block is an customize module only used for interupt data length
(
				// INPUT LOGIC ASSIGNMENT
				.HCLK					(HCLK),
				.HRESETn				(HRESETn),
				.HWriteReg			(HwriteReg),
				.HWDATA				(HWDATA),
				.SIGNAL_LENGTH		(AHBI_DataLength_ldB4),
	
				// OUTPUT LOGIC CONFIGURATION
				.PWDATA				(PWDATA)
);
endmodule
