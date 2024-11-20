module tb_APB_UART;

// Tín hi?u ??u vào
logic PCLK;
logic UARTCLK;
logic PRESETn;
logic [19:0] desired_baud_rate;
logic parity_bit_mode;
logic stop_bit_twice;
logic [1:0] fifo_en;
logic [3:0] number_data_receive;
logic [3:0] number_data_trans;
logic [6:0] ctrl_i;
logic [1:0] state_isr;
logic uart_mode_clk_sel;
logic PSEL;
logic PENABLE;
logic PWRITE;
logic [11:0] PADDR;
logic [7:0] PWDATA;
logic UART_RXD;

// Tín hi?u ??u ra
logic PREADY;
logic [31:0] PRDATA;
logic UART_TXD;

// Kh?i t?o module APB_UART
APB_UART uut (
    .PCLK(PCLK),
    .UARTCLK(UARTCLK),
    .PRESETn(PRESETn),
    .desired_baud_rate(desired_baud_rate),
    .parity_bit_mode(parity_bit_mode),
    .stop_bit_twice(stop_bit_twice),
    .fifo_en(fifo_en),
    .number_data_receive(number_data_receive),
    .number_data_trans(number_data_trans),
    .ctrl_i(ctrl_i),
    .state_isr(state_isr),
    .uart_mode_clk_sel(uart_mode_clk_sel),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .UART_RXD(UART_RXD),
    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .UART_TXD(UART_TXD)
);

// Clock generation
initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // T?o clock 100 MHz
end

// Clock UART generation
initial begin
    UARTCLK = 0;
    forever #10 UARTCLK = ~UARTCLK; // T?o clock 50 MHz
end

// Initial block for testing
initial begin
    // Reset các tín hi?u
    PRESETn = 0;
    desired_baud_rate = 20'd9600; // C?u hình baud rate
    parity_bit_mode = 0; // Parity mode (even)
    stop_bit_twice = 0; // Ch? m?t stop bit
    fifo_en = 2'b11; // Enable c? TX và RX FIFO
    number_data_receive = 4'd8;
    number_data_trans = 4'd8;
    ctrl_i = 7'b0000001; // C?u hình control
    state_isr = 2'b00; // Không có interrupt
    uart_mode_clk_sel = 0; // Ch?n UARTCLK
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 12'b000000000000;
    PWDATA = 8'b00000000;
    UART_RXD = 1'b1; // Idle line (RXD th??ng cao)

    // B? reset sau 20 ns
    #20 PRESETn = 1;

    // Start APB transaction ?? vi?t d? li?u
    #30;
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h004; // Ch?n ??a ch? ghi
    PWDATA = 8'hA5; // G?i d? li?u 0xA5 vào

    #40;
    PENABLE = 0;
    PSEL = 0;

    // Ch? ph?n h?i PREADY
    wait (PREADY == 1);

    // ??c d? li?u t? PRDATA
    #50;
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 0;
    PADDR = 12'h004; // Ch?n ??a ch? ??c

    #40;
    PENABLE = 0;
    PSEL = 0;

    // Ch? ph?n h?i PREADY và ki?m tra k?t qu?
    wait (PREADY == 1);

    // In k?t qu?
    $display("PRDATA = %h", PRDATA);

    // K?t thúc mô ph?ng
    #100;
    $finish;
end

endmodule
