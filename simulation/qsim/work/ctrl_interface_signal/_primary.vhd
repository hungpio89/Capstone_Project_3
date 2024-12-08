library verilog;
use verilog.vl_types.all;
entity ctrl_interface_signal is
    port(
        CLK             : in     vl_logic;
        RESETn          : in     vl_logic;
        PADDR           : in     vl_logic_vector(7 downto 0);
        cfg_en          : in     vl_logic;
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        state_isr_i     : in     vl_logic_vector(1 downto 0);
        ctrl_o          : out    vl_logic_vector(6 downto 0);
        state_isr_o     : out    vl_logic_vector(1 downto 0);
        cd_o            : out    vl_logic_vector(12 downto 0)
    );
end ctrl_interface_signal;
