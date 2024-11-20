module tb_ram;							// ahb_on_chip

    // Parameters
    parameter ADDR_WIDTH = 10;
    parameter DATA_WIDTH = 32;

    // Signals
    reg                   HCLK;
    reg                   HRESETn;
    reg  [ADDR_WIDTH-1:0] HADDR;
    reg                   HWRITE;
    reg  [1:0]            HTRANS;
    reg                   HSEL;
    reg                   HREADY;
    reg  [DATA_WIDTH-1:0] HWDATA;
    wire [DATA_WIDTH-1:0] HRDATA;
    wire                  HREADYOUT;

	  // Read data back and verify
	  reg [DATA_WIDTH-1:0] read_data;
    // Instantiate the DUT (Device Under Test)
    ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HTRANS(HTRANS),
        .HSEL(HSEL),
        .HREADY(HREADY),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADYOUT(HREADYOUT)
    );

    // Clock generation
    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;  // 100 MHz clock period (10ns)
    end

    // Task to reset the system
    task reset;
    begin
        HRESETn = 0;
        HSEL = 0;
        HADDR = 0;
        HWRITE = 0;
        HWDATA = 0;
        HTRANS = 2'b00;
        HREADY = 1;
        #10;  // Hold reset for 20ns
        HRESETn = 1;
    end
    endtask

    // Task to perform AHB write transaction
    task ahb_write(input [ADDR_WIDTH-1:0] address, input [DATA_WIDTH-1:0] data);
    begin
        @(posedge HCLK);
        HSEL = 1;
        HADDR = address;
        HWRITE = 1;
        HWDATA = data;
        HTRANS = 2'b10;  // Non-sequential transfer
        HREADY = 1;

        // Wait for HREADYOUT to indicate transaction is done
        @(posedge HCLK);
        wait(HREADYOUT);
        HSEL = 0;
        HTRANS = 2'b00;
    end
    endtask

    // Task to perform AHB read transaction
    task ahb_read(input [ADDR_WIDTH-1:0] address, output [DATA_WIDTH-1:0] data);
    begin
        @(posedge HCLK);
        HSEL = 1;
        HADDR = address;
        HWRITE = 0;
        HTRANS = 2'b10;  // Non-sequential transfer
        HREADY = 1;

        // Wait for HREADYOUT to indicate transaction is done
        @(posedge HCLK);
        wait(HREADYOUT);
        data = HRDATA;
        HSEL = 0;
        HTRANS = 2'b10;
    end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        reset();

        // Write data to RAM at different addresses
        ahb_write(10'h000, 32'hA5A5A5A5);
        ahb_write(10'h008, 32'h12345678);
		  ahb_write(10'h01F, 32'h88888888);
        ahb_write(10'h00C, 32'h87654321);

        ahb_read(10'h000, read_data);
        if (read_data !== 32'hA5A5A5A5) $display("Test failed at address 0x000");

        ahb_read(10'h004, read_data);
        if (read_data !== 32'h5A5A5A5A) $display("Test failed at address 0x004");

        ahb_read(10'h008, read_data);
        if (read_data !== 32'h12345678) $display("Test failed at address 0x008");
		  
		  ahb_read(10'h01F, read_data);
		  if (read_data == 32'h88888888) $display("Test success at address 0x00C");
		  else $display("Test failed at address 0x01F");

        ahb_read(10'h00C, read_data);
        if (read_data !== 32'h87654321) $display("Test failed at address 0x00C");
		  
		  ahb_read(10'h02F, read_data);
		  if (read_data == 32'h00000000) $display("Test success at address 0x00C");
		  else $display("Test failed at address 0x02F");
		  
        $display("All tests completed.");
        $finish;
    end

endmodule
