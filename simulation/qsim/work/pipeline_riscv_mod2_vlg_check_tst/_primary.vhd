library verilog;
use verilog.vl_types.all;
entity pipeline_riscv_mod2_vlg_check_tst is
    port(
        io_hex0_o       : in     vl_logic_vector(31 downto 0);
        io_hex1_o       : in     vl_logic_vector(31 downto 0);
        io_hex2_o       : in     vl_logic_vector(31 downto 0);
        io_hex3_o       : in     vl_logic_vector(31 downto 0);
        io_hex4_o       : in     vl_logic_vector(31 downto 0);
        io_hex5_o       : in     vl_logic_vector(31 downto 0);
        io_hex6_o       : in     vl_logic_vector(31 downto 0);
        io_hex7_o       : in     vl_logic_vector(31 downto 0);
        io_lcd_o        : in     vl_logic_vector(31 downto 0);
        io_ledg_o       : in     vl_logic_vector(31 downto 0);
        io_ledr_o       : in     vl_logic_vector(31 downto 0);
        pc_debug_o      : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end pipeline_riscv_mod2_vlg_check_tst;
