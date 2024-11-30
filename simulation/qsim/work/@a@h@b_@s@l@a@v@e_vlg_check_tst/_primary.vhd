library verilog;
use verilog.vl_types.all;
entity AHB_SLAVE_vlg_check_tst is
    port(
        HRDATA          : in     vl_logic_vector(31 downto 0);
        HREADYout       : in     vl_logic;
        HRESP           : in     vl_logic_vector(1 downto 0);
        PADDR           : in     vl_logic_vector(31 downto 0);
        PENABLE         : in     vl_logic;
        PSELx           : in     vl_logic;
        PWDATA          : in     vl_logic_vector(31 downto 0);
        PWRITE          : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end AHB_SLAVE_vlg_check_tst;
