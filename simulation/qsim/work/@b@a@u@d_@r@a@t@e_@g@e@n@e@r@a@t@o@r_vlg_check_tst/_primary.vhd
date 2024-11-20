library verilog;
use verilog.vl_types.all;
entity BAUD_RATE_GENERATOR_vlg_check_tst is
    port(
        baud_tick       : in     vl_logic;
        cd_count        : in     vl_logic_vector(12 downto 0);
        counter_baud    : in     vl_logic_vector(12 downto 0);
        sampler_rx      : in     vl_logic
    );
end BAUD_RATE_GENERATOR_vlg_check_tst;
