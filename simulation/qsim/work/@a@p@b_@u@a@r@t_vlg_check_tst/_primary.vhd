library verilog;
use verilog.vl_types.all;
entity APB_UART_vlg_check_tst is
    port(
        PRDATA          : in     vl_logic_vector(31 downto 0);
        PREADY          : in     vl_logic;
        UART_TXD        : in     vl_logic;
        baud_tick       : in     vl_logic;
        ctrl_rx_buffer  : in     vl_logic;
        ctrl_shift_register_rd: in     vl_logic_vector(3 downto 0);
        fifo_wr_ctrl    : in     vl_logic;
        rx_fifo_full    : in     vl_logic;
        rx_fifo_rd_ptr  : in     vl_logic_vector(4 downto 0);
        rx_fifo_wr_ptr  : in     vl_logic_vector(4 downto 0);
        rx_not_empty    : in     vl_logic;
        rx_read_en      : in     vl_logic;
        rx_write_en     : in     vl_logic;
        stop_bit_rx     : in     vl_logic;
        temp_rx         : in     vl_logic_vector(11 downto 0);
        temp_rx_1       : in     vl_logic_vector(11 downto 0);
        temp_rx_2       : in     vl_logic_vector(11 downto 0);
        sampler_rx      : in     vl_logic
    );
end APB_UART_vlg_check_tst;
