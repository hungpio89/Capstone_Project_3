library verilog;
use verilog.vl_types.all;
entity Thesis_Project_vlg_check_tst is
    port(
        HRDATA          : in     vl_logic_vector(31 downto 0);
        PADDR           : in     vl_logic_vector(31 downto 0);
        UART_TXD        : in     vl_logic;
        data_io_lcd_o   : in     vl_logic_vector(31 downto 0);
        data_io_ledr_o  : in     vl_logic_vector(31 downto 0);
        data_out        : in     vl_logic_vector(31 downto 0);
        pc_debug_o      : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end Thesis_Project_vlg_check_tst;
