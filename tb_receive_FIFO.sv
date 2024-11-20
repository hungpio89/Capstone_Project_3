module tb_receive_FIFO;

  // Parameters
  localparam CLK_PERIOD = 10;

  // Testbench Signals
  logic clk_i;
  logic rst_ni;
  logic [11:0] rd_data_i;
  logic fifo_en;
  logic ctrl_rx_buffer;
  logic RXen;
  logic done_flag;

  logic data_is_avail;
  logic [4:0] rx_ptr_addr_wr_i;
  logic [4:0] rx_ptr_addr_rd_o;
  logic [11:0] rx_data_o;

  // Instantiate the DUT (Device Under Test)
  receive_FIFO dut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .rd_data_i(rd_data_i),
    .fifo_en(fifo_en),
    .ctrl_rx_buffer(ctrl_rx_buffer),
    .RXen(RXen),
    .done_flag(done_flag),
    .data_is_avail(data_is_avail),
    .rx_ptr_addr_wr_i(rx_ptr_addr_wr_i),
    .rx_ptr_addr_rd_o(rx_ptr_addr_rd_o),
    .rx_data_o(rx_data_o)
  );

  // Clock Generation
  initial begin
    clk_i = 0;
    forever #(CLK_PERIOD / 2) clk_i = ~clk_i;
  end

  // Reset Task
  task reset_dut;
    begin
      rst_ni = 0;
      #(2 * CLK_PERIOD);
      rst_ni = 1;
    end
  endtask

  // Stimulus
  initial begin
    // Initialize signals
    rd_data_i = 0;
    fifo_en = 0;
    ctrl_rx_buffer = 0;
    RXen = 0;
    done_flag = 0;

    // Reset the DUT
    reset_dut();

    // Enable RX and FIFO
    RXen = 1;
    fifo_en = 1;

    // Write data into the FIFO
    done_flag = 1;
    for (int i = 0; i < 8; i++) begin
      rd_data_i = i + 12'h100; // Example data
      #(CLK_PERIOD);
    end
    done_flag = 0;

    // Read data from the FIFO
    ctrl_rx_buffer = 1;
    for (int i = 0; i < 8; i++) begin
      #(CLK_PERIOD);
      $display("Read data: %h", rx_data_o);
    end
    ctrl_rx_buffer = 0;

    // End simulation
    #(10 * CLK_PERIOD);
    $finish;
  end

  // Monitor signals for debugging
  initial begin
    $monitor("Time: %0t | data_is_avail: %b | rx_data_o: %h | rx_ptr_addr_wr_i: %d | rx_ptr_addr_rd_o: %d",
             $time, data_is_avail, rx_data_o, rx_ptr_addr_wr_i, rx_ptr_addr_rd_o);
  end

endmodule
