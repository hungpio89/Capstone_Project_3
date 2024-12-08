library verilog;
use verilog.vl_types.all;
entity Thesis_Project is
    port(
        data_input      : in     vl_logic_vector(9 downto 0);
        clk_i           : in     vl_logic;
        UARTCLK         : in     vl_logic;
        rst_ni          : in     vl_logic;
        pc_debug_o      : out    vl_logic_vector(31 downto 0);
        data_io_ledr_o  : out    vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0);
        UART_RXD        : in     vl_logic;
        UART_TXD        : out    vl_logic;
        HRDATA          : out    vl_logic_vector(31 downto 0);
        HADDR           : out    vl_logic_vector(31 downto 0);
        baud_tick       : out    vl_logic;
        data_trans      : out    vl_logic_vector(11 downto 0);
        data_io_lcd_o   : out    vl_logic_vector(31 downto 0)
    );
end Thesis_Project;
