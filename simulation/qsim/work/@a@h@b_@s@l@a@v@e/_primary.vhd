library verilog;
use verilog.vl_types.all;
entity AHB_SLAVE is
    port(
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HSIZES          : in     vl_logic_vector(2 downto 0);
        HBURST          : in     vl_logic_vector(2 downto 0);
        HWRITE          : in     vl_logic;
        HREADYin        : in     vl_logic;
        HWDATA          : in     vl_logic_vector(31 downto 0);
        PRDATA          : in     vl_logic_vector(31 downto 0);
        PREADY          : in     vl_logic;
        PWDATA          : out    vl_logic_vector(31 downto 0);
        PADDR           : out    vl_logic_vector(31 downto 0);
        PENABLE         : out    vl_logic;
        PWRITE          : out    vl_logic;
        HREADYout       : out    vl_logic;
        HRESP           : out    vl_logic_vector(1 downto 0);
        PSELx           : out    vl_logic;
        HRDATA          : out    vl_logic_vector(31 downto 0)
    );
end AHB_SLAVE;
