module tb_AHB_SLAVE();

//------------------CPU INPUT------------------------//
logic 						HCLK;					
logic 						HRESETn;				
//---------------------------------------------------//
	
//-----------------INPUT FROM MASTER-----------------//
logic			[  1 :  0]	HTRANS;		
logic			[  2 :  0]	HSIZES;	
logic			[  2 :  0]	HBURST;	
logic 						HWRITE;				
logic 						HREADYin;			
logic			[ 31 :  0]	HWDATA;			
logic			[ 31 :  0]	PRDATA;
logic							PREADY;
logic							HSELABPif;
//---------------------------------------------------//

//--------------------REQUESTER OUT------------------//
logic			[ 31 :  0]	PWDATA;
logic			[ 31 :  0]	PADDR;
logic 						PENABLE;
logic 						PWRITE;
logic 						HREADYout;
logic 		[  1 :  0]	HRESP;
logic 						PSELx;
logic			[ 31 :  0]	HRDATA;
//---------------------------------------------------//


// Instantiate the AHB_SLAVE module
AHB_SLAVE dut (
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.HTRANS(HTRANS),
	.HSIZES(HSIZES),
	.HBURST(HBURST),
	.HWRITE(HWRITE),
	.HREADYin(HREADYin),
	.HWDATA(HWDATA),
	.PRDATA(PRDATA),
	.PREADY(PREADY),
	.PWDATA(PWDATA),
	.PADDR(PADDR),
	.PENABLE(PENABLE),
	.PWRITE(PWRITE),
	.HREADYout(HREADYout),
	.HRESP(HRESP),
	.PSELx(PSELx),
	.HSELABPif(HSELABPif),
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
	HSIZES	= 3'b000;
	HBURST	= 3'b000;
	HWRITE   = 0;
	HWDATA   = 32'h0;
	PRDATA   = 32'h0;
	PREADY   = 0;
	
	#100;
	// Begin a transaction: Write to address 0x8000_0000
	HWRITE   = 1;
	HSELABPif = 1;
	HTRANS   = 2'b10; // Non-sequential
	HSIZES	= 3'b001;
	HBURST	= 3'b001;
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
	$monitor("Time: %0t | HWDATA: %h | HRDATA: %h | PWDATA: %h | PADDR: %h | PENABLE: %b | PWRITE: %b | PSELx: %b", 
		$time, HWDATA, HRDATA, PWDATA, PADDR, PENABLE, PWRITE, PSELx);
end

endmodule
