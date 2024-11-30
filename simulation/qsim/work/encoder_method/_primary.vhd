library verilog;
use verilog.vl_types.all;
entity encoder_method is
    port(
        HBURST          : in     vl_logic_vector(2 downto 0);
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        HADDR           : out    vl_logic_vector(31 downto 0)
    );
end encoder_method;
