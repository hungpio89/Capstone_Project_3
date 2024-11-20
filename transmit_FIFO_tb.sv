`timescale 1ns/1ps

module transmit_FIFO_tb;

    // Testbench Signals
    logic clk_i, rst_ni;
    logic [7:0] wr_data;
    logic fifo_en, ctrl_tx_buffer, done_tx, TXen, tx_buffer_overrun, rx_state_full;
    logic [4:0] ptr_addr_wr_i, ptr_addr_wr_o;
    logic [7:0] wr_data_o;

    // Instantiate the DUT
    transmit_FIFO uut (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .wr_data(wr_data),
        .fifo_en(fifo_en),
        .ctrl_tx_buffer(ctrl_tx_buffer),
        .done_tx(done_tx),
        .TXen(TXen),
        .tx_buffer_overrun(tx_buffer_overrun),
        .rx_state_full(rx_state_full),
        .ptr_addr_wr_i(ptr_addr_wr_i),
        .ptr_addr_wr_o(ptr_addr_wr_o),
        .wr_data_o(wr_data_o)
    );

    // Clock Generation
    initial clk_i = 0;
    always #5 clk_i = ~clk_i;  // 100 MHz clock

    // Test Scenarios
    initial begin
        // Initialize inputs
        rst_ni = 0;
        wr_data = 8'd0;
        fifo_en = 0;
        ctrl_tx_buffer = 0;
        done_tx = 0;
        TXen = 0;
        tx_buffer_overrun = 0;
        rx_state_full = 0;

        // Reset Sequence
        #10 rst_ni = 1;  // Release reset

        // Test 1: Write data to FIFO
        TXen = 1;
        fifo_en = 1;
        wr_data = 8'd10;
        #10;
        wr_data = 8'd20;
        #10;
        wr_data = 8'd30;
        #10;

        // Test 2: Read data from FIFO
        fifo_en = 1;
        ctrl_tx_buffer = 1;  // Enable reading
        done_tx = 1;
        #10;
        done_tx = 0;
        #10;
        done_tx = 1;
        #10;

        // Test 3: Full FIFO clear
        rx_state_full = 1;  // Simulate full FIFO
        #10;
        rx_state_full = 0;

        // Test 4: No FIFO operation
        fifo_en = 0;
        ctrl_tx_buffer = 0;
        wr_data = 8'd40;
        #10;

        // End simulation
        $stop;
    end

    // Monitor Outputs
    always @(posedge clk_i) begin
        $display("Time=%0t, ptr_addr_wr_i=%0d, ptr_addr_wr_o=%0d, wr_data_o=%0d",
                 $time, ptr_addr_wr_i, ptr_addr_wr_o, wr_data_o);
    end

endmodule
