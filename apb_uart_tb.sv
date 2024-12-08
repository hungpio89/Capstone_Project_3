module testbench_APB_UART;

// Tín hiệu đầu vào
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

// Tín hiệu đầu ra
logic PREADY;
logic [31:0] PRDATA;
logic UART_TXD;
logic	baud_tick;
logic	[   6 :   0]	UART_ERRORS;

// Delete later
logic	[11:0] data_trans;
logic 		 rx_write_en;
logic				rx_read_en;
logic						ctrl_rx_buffer;

parameter CLK_PERIOD = 2; // Thời gian chu kỳ đồng hồ (10 ns cho 100 MHz)

// Khởi tạo module APB_UART
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
    .UART_TXD(UART_TXD),
	 .UART_ERRORS(UART_ERRORS),
	 .baud_tick(baud_tick),
	 .data_trans(data_trans),
	 .rx_write_en(rx_write_en),
	 .rx_read_en(rx_read_en),
	 .ctrl_rx_buffer(ctrl_rx_buffer)
);

// Clock generation
initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK; // Tạo clock 100 MHz
end

// Clock UART generation
initial begin
    UARTCLK = 0;
    forever #10 UARTCLK = ~UARTCLK; // Tạo clock 50 MHz
end

// Initial block for testing
initial begin

    // Reset các tín hiệu
    PRESETn = 0;
    desired_baud_rate = 20'd460800; // Cấu hình baud rate
    parity_bit_mode = 1; // Parity mode (even)
    stop_bit_twice = 1; // Chỉ một stop bit
    fifo_en = 2'b11; // Enable cả TX và RX FIFO
    number_data_receive = 4'd8;
    number_data_trans = 4'd8;
    ctrl_i = 7'b0000000; // Cấu hình control
    state_isr = 2'b00; // Không có interrupt
    uart_mode_clk_sel = 0; // Chọn UARTCLK
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = 12'b000000000000;
    PWDATA = 8'b00000000;
    UART_RXD = 1'b1; // Idle line (RXD thường cao)

    // Bỏ reset sau 20 ns và bắt đầu write
    #20 
	 PRESETn = 1;
	 ctrl_i = 7'b0000011;
	 
    // Start APB transaction để viết dữ liệu
	 
	 // config the baud rate
    #30;
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h410; // Chọn địa chỉ ghi
	 
	 // config write transaction (ctrl)
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h408; // Chọn địa chỉ ghi
	 
	 // config state transaction
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h404; // Chọn địa chỉ ghi
	 
	 // start write transaction
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'hD8; // Gửi dữ liệu 0xA5 vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	 
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'h48; // Gửi dữ liệu 'H vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	 
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'h45; // Gửi dữ liệu 'E vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	 
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'h4C; // Gửi dữ liệu 'L vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	 
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'h4C; // Gửi dữ liệu 'L vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	 
	 #30;
	 PSEL = 1;
    PENABLE = 1;
    PWRITE = 1;
    PADDR = 12'h400; // Chọn địa chỉ ghi
    PWDATA = 8'h4F; // Gửi dữ liệu 'O vào
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
	 @(posedge PREADY);
	
	 #20 
	 PRESETn = 0;
	 #200 
	 PRESETn = 1;
	
	 // Đọc dữ liệu state
    @(posedge baud_tick);
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 0;
    PADDR = 12'h400; // Chọn địa chỉ đọc
	 
	 // Đọc dữ liệu ctrl
    @(posedge baud_tick);
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 0;
    PADDR = 12'h404; // Chọn địa chỉ đọc
	 
	 // Đọc dữ liệu cd
    
    @(posedge baud_tick);
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 0;
    PADDR = 12'h408; // Chọn địa chỉ đọc
	 
    // Đọc dữ liệu từ PRDATA
	 
    @(posedge baud_tick);
    #30;
    PSEL = 1;
    PENABLE = 1;
    PWRITE = 0;
    PADDR = 12'h410; // Chọn địa chỉ đọc
	 
	 // Start bit
    @(posedge baud_tick);
    UART_RXD = 0; // Start bit (0)
    
    // Data bits
	 
	 // character m
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 0 (1)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 1 (0)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 2 (1)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 3 (1)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 4 (0)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 5 (1)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 6 (1)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 7 (0)
    
    // Parity bit (even parity)
	 @(posedge baud_tick);
    UART_RXD = 0; // Parity bit (1) - even parity
    
    // Stop bit
	 @(posedge baud_tick);
    UART_RXD = 1; // Stop bit (1)
	 @(posedge baud_tick);
    UART_RXD = 1; // Stop bit (1) 

	 // Chờ phản hồi PREADY và kiểm tra kết quả
//    wait (PREADY == 1);
    #3000;
	 
	 // Start bit
    @(posedge baud_tick);
    UART_RXD = 0; // Start bit (0)
    
    // Data bits
	 
	 // character y
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 0 (1)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 1 (0)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 2 (0)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 3 (1)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 4 (1)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 5 (1)
    @(posedge baud_tick);
    UART_RXD = 1; // Data bit 6 (1)
    @(posedge baud_tick);
    UART_RXD = 0; // Data bit 7 (0)
    
    // Parity bit (even parity)
	 @(posedge baud_tick);
    UART_RXD = 1; // Parity bit (1) - even parity
    
    // Stop bit
	 @(posedge baud_tick);
    UART_RXD = 1; // Stop bit (1)
	 @(posedge baud_tick);
    UART_RXD = 1; // Stop bit (1)

    #3000;
	 
	 // Start bit
    @(posedge baud_tick);
    UART_RXD = 1; // Start bit (0)
	 
	  @(posedge baud_tick);
    UART_RXD = 1; // Start
	 
	 // Chờ phản hồi PREADY và kiểm tra kết quả
    wait (PREADY == 1);
    #30;
	 
    PENABLE = 0;
    PSEL = 0;

    // In kết quả
    $display("PRDATA = %h", PRDATA);

    // Kết thúc mô phỏng
    #100;
end

endmodule
