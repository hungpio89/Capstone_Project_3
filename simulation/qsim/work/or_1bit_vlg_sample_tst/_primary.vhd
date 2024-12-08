library verilog;
use verilog.vl_types.all;
entity or_1bit_vlg_sample_tst is
    port(
        data_in1        : in     vl_logic;
        data_in2        : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end or_1bit_vlg_sample_tst;
