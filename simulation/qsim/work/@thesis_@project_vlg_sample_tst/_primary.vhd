library verilog;
use verilog.vl_types.all;
entity Thesis_Project_vlg_sample_tst is
    port(
        UARTCLK         : in     vl_logic;
        UART_RXD        : in     vl_logic;
        clk_i           : in     vl_logic;
        data_input      : in     vl_logic_vector(9 downto 0);
        rst_ni          : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end Thesis_Project_vlg_sample_tst;
