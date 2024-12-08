library verilog;
use verilog.vl_types.all;
entity AHB_APB_UART_vlg_check_tst is
    port(
        HADDR           : in     vl_logic_vector(31 downto 0);
        HRDATA          : in     vl_logic_vector(31 downto 0);
        HREADYout       : in     vl_logic;
        HRESP           : in     vl_logic_vector(1 downto 0);
        UART_TXD        : in     vl_logic;
        baud_tick       : in     vl_logic;
        data_trans      : in     vl_logic_vector(11 downto 0);
        sampler_rx      : in     vl_logic
    );
end AHB_APB_UART_vlg_check_tst;
