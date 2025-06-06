library verilog;
use verilog.vl_types.all;
entity APB_UART is
    port(
        PCLK            : in     vl_logic;
        UARTCLK         : in     vl_logic;
        PRESETn         : in     vl_logic;
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        parity_bit_mode : in     vl_logic;
        stop_bit_twice  : in     vl_logic;
        fifo_en         : in     vl_logic_vector(1 downto 0);
        number_data_receive: in     vl_logic_vector(3 downto 0);
        number_data_trans: in     vl_logic_vector(3 downto 0);
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        state_isr       : in     vl_logic_vector(1 downto 0);
        uart_mode_clk_sel: in     vl_logic;
        PSEL            : in     vl_logic;
        PENABLE         : in     vl_logic;
        PWRITE          : in     vl_logic;
        PADDR           : in     vl_logic_vector(11 downto 0);
        PWDATA          : in     vl_logic_vector(7 downto 0);
        PREADY          : out    vl_logic;
        PRDATA          : out    vl_logic_vector(31 downto 0);
        UART_RXD        : in     vl_logic;
        UART_TXD        : out    vl_logic;
        baud_tick       : out    vl_logic
    );
end APB_UART;
