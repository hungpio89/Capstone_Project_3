`timescale 1ns / 1ps

module tb_sram;

    // Parameters
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 10;
    localparam NUM_BANKS = 4;

    // Signals
	 logic [2:0] 				HBURST;
	 logic [2:0] 				HSIZE;
    logic                  HCLK;
    logic                  HRESETn;
    logic [ADDR_WIDTH-1:0] HADDR;
    logic                  HWRITE;
    logic [1:0]            HTRANS;
    logic                  HSEL;
    logic                  HREADY;
    logic [DATA_WIDTH-1:0] HWDATA;
    logic [DATA_WIDTH-1:0] HRDATA;
    logic                  HREADYOUT;
    logic                  ecc_error;
	 logic [DATA_WIDTH-1:0] read_data;
    // Clock generation
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK; // 100 MHz clock
    end

    // DUT instantiation
    sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .NUM_BANKS(NUM_BANKS)
    ) dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
		  .HBURST(HBURST),
		  .HSIZE(HSIZE),
        .HSEL(HSEL),
        .HREADY(HREADY),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADYOUT(HREADYOUT),
        .ecc_error(ecc_error)
    );

    // Tasks for driving AHB transactions
    task ahb_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(posedge HCLK);
            HSEL <= 1'b1;
            HWRITE <= 1'b1;
            HTRANS <= 2'b10; // NONSEQ
            HADDR <= addr;
            HWDATA <= data;
            HREADY <= 1'b1;
            @(posedge HCLK);
            HSEL <= 1'b0;
            HWRITE <= 1'b0;
            HTRANS <= 2'b00; // IDLE
        end
    endtask

    task ahb_read(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data);
        begin
            @(posedge HCLK);
            HSEL <= 1'b1;
            HWRITE <= 1'b0;
            HTRANS <= 2'b10; // NONSEQ
            HADDR <= addr;
            HREADY <= 1'b1;
            @(posedge HCLK);
            data = HRDATA;
            HSEL <= 1'b0;
            HTRANS <= 2'b00; // IDLE
        end
    endtask

    // Reset sequence
    initial begin
        HRESETn = 0;
        #20;
        HRESETn = 1;
    end

    // Test scenarios
    initial begin
        // Initialize signals
        HSEL = 0;
        HWRITE = 0;
        HTRANS = 0;
		  HSIZE	= 3'b000;
		  HBURST = 3'b001;
        HADDR = 0;
        HWDATA = 0;
        HREADY = 1;

        // Wait for reset deassertion
        @(posedge HRESETn);

        // Test 1: Write to SRAM and read back
        ahb_write(10'h001, 32'hDEADBEEF); // Write to address 0x001
        ahb_read(10'h001, read_data);     // Read from address 0x001
        assert(read_data == 32'hDEADBEEF) else $error("Test 1 failed: Read data mismatch");

        // Test 2: Write to multiple banks
        ahb_write(10'h041, 32'hCAFEBABE); // Write to address in bank 1
        ahb_write(10'h081, 32'h12345678); // Write to address in bank 2

        ahb_read(10'h041, read_data);     // Read from address in bank 1
        assert(read_data == 32'hCAFEBABE) else $error("Test 2 failed: Bank 1 data mismatch");

        ahb_read(10'h081, read_data);     // Read from address in bank 2
        assert(read_data == 32'h12345678) else $error("Test 2 failed: Bank 2 data mismatch");

        // Test 3: ECC error injection and detection
        // Simulate a single-bit error
        dut.mem_array[0][1][31] = ~dut.mem_array[0][1][31]; // Flip a bit in stored data
        ahb_read(10'h001, read_data);
        assert(ecc_error == 1) else $error("Test 3 failed: ECC error not detected");

        // Reset ECC error flag
        dut.mem_array[0][1][31] = ~dut.mem_array[0][1][31]; // Restore the original bit

        // Test 4: Check HREADYOUT behavior
        ahb_write(10'h003, 32'hA5A5A5A5);
        @(posedge HCLK);
        assert(HREADYOUT == 1'b1) else $error("Test 4 failed: HREADYOUT not asserted");

        // Test complete
        $display("All tests passed!");
        $finish;
    end
endmodule
