library verilog;
use verilog.vl_types.all;
entity or_1bit is
    port(
        data_in1        : in     vl_logic;
        data_in2        : in     vl_logic;
        data_out        : out    vl_logic
    );
end or_1bit;
