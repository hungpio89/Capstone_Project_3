library verilog;
use verilog.vl_types.all;
entity pipeline_riscv_mod2_vlg_sample_tst is
    port(
        clk_i           : in     vl_logic;
        io_sw_i         : in     vl_logic_vector(31 downto 0);
        rst_ni          : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end pipeline_riscv_mod2_vlg_sample_tst;
