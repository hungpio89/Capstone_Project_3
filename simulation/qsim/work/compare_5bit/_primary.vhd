library verilog;
use verilog.vl_types.all;
entity compare_5bit is
    port(
        A               : in     vl_logic_vector(5 downto 0);
        B               : in     vl_logic_vector(5 downto 0);
        A_less_B        : out    vl_logic
    );
end compare_5bit;
