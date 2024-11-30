library verilog;
use verilog.vl_types.all;
entity encoder_method_vlg_sample_tst is
    port(
        HBURST          : in     vl_logic_vector(2 downto 0);
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end encoder_method_vlg_sample_tst;
