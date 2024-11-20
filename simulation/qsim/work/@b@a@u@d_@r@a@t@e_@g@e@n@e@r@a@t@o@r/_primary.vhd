library verilog;
use verilog.vl_types.all;
entity BAUD_RATE_GENERATOR is
    port(
        uart_ref_clk    : in     vl_logic;
        rst_n           : in     vl_logic;
        uart_mode_sel   : in     vl_logic;
        baud_div_16     : in     vl_logic;
        cd              : in     vl_logic_vector(12 downto 0);
        baud_tick       : out    vl_logic;
        counter_baud    : out    vl_logic_vector(12 downto 0);
        cd_count        : out    vl_logic_vector(12 downto 0)
    );
end BAUD_RATE_GENERATOR;
