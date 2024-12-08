module tb_error_ram;

    // Parameters
    parameter DEPTH = 1024;

    // Testbench signals
    logic        clk;
    logic        rst_n;
    logic        write_enable;
    logic [31:0] write_address;
    logic [9:0]  write_error;
    logic        read_enable;
    logic [31:0] read_address;
    logic [9:0]  read_error;

    // Instantiate the DUT (Device Under Test)
    error_ram #(.DEPTH(DEPTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .write_address(write_address),
        .write_error(write_error),
        .read_enable(read_enable),
        .read_address(read_address),
        .read_error(read_error)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock (10 ns period)

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        write_enable = 0;
        write_address = 32'b0;
        write_error = 10'b0;
        read_enable = 0;
        read_address = 32'b0;

        // Reset the design
        #10 rst_n = 1;

        // Test case 1: Write and read a single entry
        @(posedge clk);
        write_enable = 1;
        write_address = 32'hAABBCCDD;
        write_error = 10'b1010101010;

        @(posedge clk);
        write_enable = 0;

        // Read the same address
        @(posedge clk);
        read_enable = 1;
        read_address = 32'hAABBCCDD;

        @(posedge clk);
        $display("Test 1: Read error = %b (Expected: 1010101010)", read_error);
        read_enable = 0;

        // Test case 2: Write multiple entries and read them
        @(posedge clk);
        write_enable = 1;
        write_address = 32'h12345678;
        write_error = 10'b1110001110;

        @(posedge clk);
        write_address = 32'h87654321;
        write_error = 10'b0001110001;

        @(posedge clk);
        write_enable = 0;

        // Read first entry
        @(posedge clk);
        read_enable = 1;
        read_address = 32'h12345678;

        @(posedge clk);
        $display("Test 2a: Read error = %b (Expected: 1110001110)", read_error);

        // Read second entry
        @(posedge clk);
        read_address = 32'h87654321;

        @(posedge clk);
        $display("Test 2b: Read error = %b (Expected: 0001110001)", read_error);
        read_enable = 0;

        // Test case 3: Read an address not written
        @(posedge clk);
        read_enable = 1;
        read_address = 32'hDEADBEEF;

        @(posedge clk);
        $display("Test 3: Read error = %b (Expected: 0000000000)", read_error);
        read_enable = 0;

        // End simulation
        #20;
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t, Write_Enable=%b, Write_Addr=0x%h, Write_Err=%b, Read_Enable=%b, Read_Addr=0x%h, Read_Err=%b",
                 $time, write_enable, write_address, write_error, read_enable, read_address, read_error);
    end

endmodule
