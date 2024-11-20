module BAUD_RATE_GENERATOR_tb;

    // Input signals
    logic uart_ref_clk;
    logic rst_n;
    logic uart_mode_sel;
    logic baud_div_16;
    logic [12:0] cd;
    
    // Output signals
    logic baud_tick;

    // Instantiate the module under test (MUT)
    BAUD_RATE_GENERATOR uut (
        .uart_ref_clk			(uart_ref_clk),
        .rst_n						(rst_n),
        .uart_mode_sel			(uart_mode_sel),
        .baud_div_16				(baud_div_16),
        .cd							(cd),
        .baud_tick				(baud_tick)
    );

    // Generate uart_ref_clk for any module dependencies
    initial begin
        uart_ref_clk = 0;
        forever #5 uart_ref_clk = ~uart_ref_clk;  // 10 ns clock period (100 MHz)
    end

    // Generate baud_div_16 as a divided clock (simulating it being already divided by 16)
    initial begin
        baud_div_16 = 0;
        forever #40 baud_div_16 = ~baud_div_16;  // Slower clock for baud_div_16
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst_n = 1;
        uart_mode_sel = 0;
        cd = 13'd8;  // Initial divisor for the baud rate
        
        // Apply reset
        #10 rst_n = 0;

        // Wait and release reset
        #20 rst_n = 1;

        // Test Case 1: Observe `baud_tick` output as `baud_div_16` toggles
        #500;
        
        // Test Case 2: Change `cd` value to test different baud rates
        #100 cd = 13'd10;
        
        // Observe the behavior
        #500 cd = 13'd5;

        // Test Case 3: Toggle `uart_mode_sel`
        #100 uart_mode_sel = 1;

        // Continue simulation to observe behavior
        #1000 $stop;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t | rst_n = %b | baud_div_16 = %b | cd = %0d | baud_tick = %b", 
                 $time, rst_n, baud_div_16, cd, baud_tick);
    end

endmodule
