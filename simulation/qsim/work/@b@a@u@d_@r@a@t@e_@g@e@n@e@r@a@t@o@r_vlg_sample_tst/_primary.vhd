library verilog;
use verilog.vl_types.all;
entity BAUD_RATE_GENERATOR_vlg_sample_tst is
    port(
        baud_div_16     : in     vl_logic;
        cd              : in     vl_logic_vector(12 downto 0);
        rst_n           : in     vl_logic;
        uart_mode_sel   : in     vl_logic;
        uart_ref_clk    : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end BAUD_RATE_GENERATOR_vlg_sample_tst;
