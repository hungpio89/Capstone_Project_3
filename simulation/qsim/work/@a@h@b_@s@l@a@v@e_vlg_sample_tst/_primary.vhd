library verilog;
use verilog.vl_types.all;
entity AHB_SLAVE_vlg_sample_tst is
    port(
        HBURST          : in     vl_logic_vector(2 downto 0);
        HCLK            : in     vl_logic;
        HREADYin        : in     vl_logic;
        HRESETn         : in     vl_logic;
        HSIZES          : in     vl_logic_vector(2 downto 0);
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HWDATA          : in     vl_logic_vector(31 downto 0);
        HWRITE          : in     vl_logic;
        PRDATA          : in     vl_logic_vector(31 downto 0);
        PREADY          : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end AHB_SLAVE_vlg_sample_tst;
