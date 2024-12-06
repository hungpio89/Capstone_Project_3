`timescale 1ns/1ps

module tb_ahb_master;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter TRANS_SIZE = 32;

    // Clock and reset signals
    reg hclk;
    reg hresetn;

    // Signals to connect with DUT
    wire [ADDR_WIDTH-1:0] haddr;
    wire [DATA_WIDTH-1:0] hwdata;
    wire hwrite;
    wire [2:0] hburst;
    wire [1:0] htrans;
    wire [2:0] hsize;
    reg [DATA_WIDTH-1:0] hrdata;
    reg hready;
    reg [1:0] hresp;

    reg stop_trans;
    reg start_trans;
    reg [ADDR_WIDTH-1:0] ext_haddr;
    reg [DATA_WIDTH-1:0] ext_hwdata;
    reg ext_hwrite;
    reg [2:0] ext_hburst;
    reg [2:0] ext_hsize;
    wire [31:0] ext_hrdata;

    // DUT instantiation
    ahb_master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .TRANS_SIZE(TRANS_SIZE)
    ) dut (
        .hclk(hclk),
        .hresetn(hresetn),
        .haddr(haddr),
        .hwdata(hwdata),
        .hwrite(hwrite),
        .hburst(hburst),
        .htrans(htrans),
        .hsize(hsize),
        .hrdata(hrdata),
        .hready(hready),
        .hresp(hresp),
        .stop_trans(stop_trans),
        .start_trans(start_trans),
        .ext_haddr(ext_haddr),
        .ext_hwdata(ext_hwdata),
        .ext_hwrite(ext_hwrite),
        .ext_hburst(ext_hburst),
        .ext_hsize(ext_hsize),
        .ext_hrdata(ext_hrdata)
    );

    // Clock generation
    initial begin
        hclk = 0;
        forever #5 hclk = ~hclk; // 100 MHz clock
    end

    // Reset sequence
    initial begin
        hresetn = 0;
        #20 hresetn = 1;
    end

    // Stimulus process
    initial begin
        // Initialize signals
        stop_trans = 0;
        start_trans = 0;
        ext_haddr = 32'h0000_0000;
        ext_hwdata = 32'h1234_5678;
        ext_hwrite = 0;
        ext_hburst = 3'd0; // Single transfer
        ext_hsize = 3'b010; // 32-bit transfer
        hrdata = 32'h0;
        hready = 1;
        hresp = 2'd0;

        // Wait for reset to de-assert
        @(negedge hresetn);
        @(posedge hresetn);

        // Test single write transfer
        #10 start_trans = 1;
        ext_hwrite = 1;
        ext_haddr = 32'h1000_0000;
        ext_hwdata = 32'hDEAD_BEEF;
        @(posedge hclk);
        start_trans = 0;

        // Wait for the transfer to complete
        @(posedge hclk);
        while (htrans != 2'd0) @(posedge hclk);

        // Test single read transfer
        #10 start_trans = 1;
        ext_hwrite = 0;
        ext_haddr = 32'h1000_0000;
        hrdata = 32'hBAD_C0DE;
        @(posedge hclk);
        start_trans = 0;

        // Wait for the transfer to complete
        @(posedge hclk);
        while (htrans != 2'd0) @(posedge hclk);

        // Test incrementing burst transfer (4 beats)
        #10 start_trans = 1;
        ext_hwrite = 1;
        ext_hburst = 3'd3; // Incrementing burst, 4 beats
        ext_haddr = 32'h2000_0000;
        ext_hwdata = 32'hFACE_FEED;
        @(posedge hclk);
        start_trans = 0;

        // Wait for the burst transfer to complete
        @(posedge hclk);
        while (htrans != 2'd0) @(posedge hclk);

        // End of simulation
        #100 $stop;
    end

    // Monitor signals
    initial begin
        $monitor($time, " hclk=%b hresetn=%b haddr=0x%h hwdata=0x%h hwrite=%b hburst=%b htrans=%b hsize=%b hrdata=0x%h",
                 hclk, hresetn, haddr, hwdata, hwrite, hburst, htrans, hsize, hrdata);
    end

endmodule
