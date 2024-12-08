library verilog;
use verilog.vl_types.all;
entity ctrl_interface_signal_vlg_check_tst is
    port(
        cd_o            : in     vl_logic_vector(12 downto 0);
        ctrl_o          : in     vl_logic_vector(6 downto 0);
        state_isr_o     : in     vl_logic_vector(1 downto 0);
        sampler_rx      : in     vl_logic
    );
end ctrl_interface_signal_vlg_check_tst;
