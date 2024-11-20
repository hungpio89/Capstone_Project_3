`timescale 1ns/1ps

module arbiter_tb;

    parameter NUM_MASTERS = 4;

    // Clock and reset
    logic hclk;
    logic hresetn;

    // Arbiter inputs
    logic [NUM_MASTERS-1:0] hreq;  // Requests from AHB masters
    logic hready;                  // Ready signal from APB bridge

    // Arbiter outputs
    logic [NUM_MASTERS-1:0] hgrant;  // Grants to AHB masters

    // Instantiate the priority-based arbiter
    arbiter #(.NUM_MASTERS(NUM_MASTERS)) uut (
        .hclk(hclk),
        .hresetn(hresetn),
        .hreq(hreq),
        .hready(hready),
        .hgrant(hgrant)
    );

    // Clock generation
    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk;  // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize inputs
        hresetn = 0;
        hreq = 0;
        hready = 1;

        // Release reset
        #20 hresetn = 1;

        // Test 1: Single request
        $display("Test 1: Single request");
        hreq = 4'b0001;  // Master 0 requests
        #20;
        assert(hgrant == 4'b0001) else $error("Test 1 failed");

        // Test 2: Multiple requests with priority
        $display("Test 2: Multiple requests with priority");
        hreq = 4'b1010;  // Masters 1 and 3 request
        #20;
        assert(hgrant == 4'b1000) else $error("Test 2 failed: Master 3 not granted");
        hready = 1;
        #20;
        hreq = 4'b0110;  // Masters 1 and 2 request
        assert(hgrant == 4'b0100) else $error("Test 2 failed: Master 2 not granted");

        // Test 3: No requests
        $display("Test 3: No requests");
        hreq = 4'b0000;
        #20;
        assert(hgrant == 4'b0000) else $error("Test 3 failed");

        $display("All tests completed successfully.");
        $finish;
    end

endmodule
