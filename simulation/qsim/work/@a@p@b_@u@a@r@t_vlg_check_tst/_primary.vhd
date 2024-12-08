library verilog;
use verilog.vl_types.all;
entity APB_UART_vlg_check_tst is
    port(
        PRDATA          : in     vl_logic_vector(31 downto 0);
        PREADY          : in     vl_logic;
        UART_TXD        : in     vl_logic;
        baud_tick       : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end APB_UART_vlg_check_tst;
