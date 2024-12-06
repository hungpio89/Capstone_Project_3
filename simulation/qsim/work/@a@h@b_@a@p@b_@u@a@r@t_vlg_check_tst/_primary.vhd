library verilog;
use verilog.vl_types.all;
entity AHB_APB_UART_vlg_check_tst is
    port(
        HRDATA          : in     vl_logic_vector(31 downto 0);
        HREADYout       : in     vl_logic;
        HRESP           : in     vl_logic_vector(1 downto 0);
        PADDR           : in     vl_logic_vector(31 downto 0);
        UART_TXD        : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end AHB_APB_UART_vlg_check_tst;
