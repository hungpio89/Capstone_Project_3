library verilog;
use verilog.vl_types.all;
entity pipeline_riscv_mod2 is
    port(
        io_sw_i         : in     vl_logic_vector(31 downto 0);
        clk_i           : in     vl_logic;
        rst_ni          : in     vl_logic;
        pc_debug_o      : out    vl_logic_vector(31 downto 0);
        io_lcd_o        : out    vl_logic_vector(31 downto 0);
        io_ledg_o       : out    vl_logic_vector(31 downto 0);
        io_ledr_o       : out    vl_logic_vector(31 downto 0);
        io_hex0_o       : out    vl_logic_vector(31 downto 0);
        io_hex1_o       : out    vl_logic_vector(31 downto 0);
        io_hex2_o       : out    vl_logic_vector(31 downto 0);
        io_hex3_o       : out    vl_logic_vector(31 downto 0);
        io_hex4_o       : out    vl_logic_vector(31 downto 0);
        io_hex5_o       : out    vl_logic_vector(31 downto 0);
        io_hex6_o       : out    vl_logic_vector(31 downto 0);
        io_hex7_o       : out    vl_logic_vector(31 downto 0)
    );
end pipeline_riscv_mod2;
