library verilog;
use verilog.vl_types.all;
entity encoder_method_vlg_check_tst is
    port(
        HADDR           : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end encoder_method_vlg_check_tst;
