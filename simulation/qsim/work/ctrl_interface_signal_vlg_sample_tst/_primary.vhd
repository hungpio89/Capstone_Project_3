library verilog;
use verilog.vl_types.all;
entity ctrl_interface_signal_vlg_sample_tst is
    port(
        CLK             : in     vl_logic;
        PADDR           : in     vl_logic_vector(7 downto 0);
        RESETn          : in     vl_logic;
        cfg_en          : in     vl_logic;
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        state_isr_i     : in     vl_logic_vector(1 downto 0);
        sampler_tx      : out    vl_logic
    );
end ctrl_interface_signal_vlg_sample_tst;
