module tb_AHB_SLAVE();

//------------------CPU INPUT------------------------//
reg 					HCLK;					
reg 					HRESETn;				
//---------------------------------------------------//
	
//-----------------INPUT FROM MASTER-----------------//
reg		[  1 :  0]	HTRANS;				
reg 					HWRITE;				
reg 					HREADYin;			
reg		[ 31 :  0]	HWDATA;
reg		[ 31 :  0]	HADDR;				
reg		[ 31 :  0]	PRDATA;
reg						PREADY;
//---------------------------------------------------//

//--------------------REQUESTER OUT------------------//
wire		[ 31 :  0]	PWDATA;
wire		[ 31 :  0]	PADDR;
wire 					PENABLE;
wire 					PWRITE;
wire 					HREADYout;
wire 	[  1 :  0]	HRESP;
wire 					PSELx;
wire		[ 31 :  0]	HRDATA;
//---------------------------------------------------//

// Instantiate the AHB_SLAVE module
AHB_SLAVE dut (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.HTRANS(HTRANS),
	.HWRITE(HWRITE),
	.HREADYin(HREADYin),
	.HWDATA(HWDATA),
	.HADDR(HADDR),
	.PRDATA(PRDATA),
	.PREADY(PREADY),
	.PWDATA(PWDATA),
	.PADDR(PADDR),
	.PENABLE(PENABLE),
	.PWRITE(PWRITE),
	.HREADYout(HREADYout),
	.HRESP(HRESP),
	.PSELx(PSELx),
	.HRDATA(HRDATA)
);

// Clock generation (50 MHz)
initial begin
	HCLK = 0;
	forever #10 HCLK = ~HCLK; // 50 MHz clock with 20 ns period
end

// Reset logic
initial begin
	HRESETn = 0;
	#40 HRESETn = 1; // Reset for the first 50 ns
end

// Test stimulus
initial begin
	// Initialize inputs
	HREADYin = 0;
	HTRANS   = 2'b00;
	HWRITE   = 0;
	HWDATA   = 32'h0;
	HADDR    = 32'h0;
	PRDATA   = 32'h0;
	PREADY   = 0;
	
	#100;
	// Begin a transaction: Write to address 0x8000_0000
	HADDR    = 32'h8000_0000;
	HWRITE   = 1;
	HTRANS   = 2'b10; // Non-sequential
	HWDATA   = 32'h12345678;
	HREADYin = 1;
	
	#100;
	// Check for enable signals
	PRDATA = 32'h87654321;
	PREADY = 1;
	
	#20;
	// End transaction
	HREADYin = 0;
	HTRANS   = 2'b01; // IDLE
	
	#100;
	// Read transaction: Read from address 0x8000_0004
	HADDR    = 32'h8000_0004;
	HWRITE   = 0;
	HTRANS   = 2'b11; // Sequential
	HREADYin = 1;

	#20;
	// End transaction
	HREADYin = 0;
	HTRANS   = 2'b00; // IDLE
	
	#100;
	$finish;
end

// Monitor signals
initial begin
	$monitor("Time: %0t | HADDR: %h | HWDATA: %h | HRDATA: %h | PWDATA: %h | PADDR: %h | PENABLE: %b | PWRITE: %b | PSELx: %b", 
		$time, HADDR, HWDATA, HRDATA, PWDATA, PADDR, PENABLE, PWRITE, PSELx);
end

endmodule
