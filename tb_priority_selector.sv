module tb_priority_selector;

    // Parameters
    parameter NUM_INPUTS = 4;
    parameter DATA_WIDTH = 8;

    // Testbench signals
    logic [NUM_INPUTS-1:0] req;
    logic [DATA_WIDTH-1:0] data_in [NUM_INPUTS-1:0];
    logic [DATA_WIDTH-1:0] data_out;
    logic [$clog2(NUM_INPUTS)-1:0] grant;

    // DUT instantiation
    priority_selector #(
        .NUM_INPUTS(NUM_INPUTS),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .req(req),
        .data_in(data_in),
        .data_out(data_out),
        .grant(grant)
    );

    // Task to display outputs
    task display_status;
        $display("Time: %0t | req: %b | data_out: %h | grant: %0d", 
                 $time, req, data_out, grant);
    endtask

    // Test sequence
    initial begin
        // Initialize inputs
        req = 4'b0000;
        data_in[0] = 8'h11; // Data from source 0
        data_in[1] = 8'h22; // Data from source 1
        data_in[2] = 8'h33; // Data from source 2
        data_in[3] = 8'h44; // Data from source 3

        $display("Starting Priority Selector Testbench...");

        // Test case 1: No requests active
        #10 req = 4'b0000;
        #10 display_status();

        // Test case 2: Single request from source 1
        #10 req = 4'b0010;
        #10 display_status();

        // Test case 3: Single request from source 3
        #10 req = 4'b1000;
        #10 display_status();

        // Test case 4: Multiple requests (source 2 and 0 active)
        #10 req = 4'b0101;
        #10 display_status();

        // Test case 5: All sources request (highest priority: source 0)
        #10 req = 4'b1111;
        #10 display_status();

        // Test case 6: Clear requests
        #10 req = 4'b0000;
        #10 display_status();

        // End simulation
        #10 $display("Testbench completed.");
        $stop;
    end

endmodule
