library verilog;
use verilog.vl_types.all;
entity AHB_APB_UART_vlg_sample_tst is
    port(
        HBURST          : in     vl_logic_vector(2 downto 0);
        HCLK            : in     vl_logic;
        HREADYin        : in     vl_logic;
        HRESETn         : in     vl_logic;
        HSELABPif       : in     vl_logic;
        HSIZES          : in     vl_logic_vector(2 downto 0);
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HWDATA          : in     vl_logic_vector(31 downto 0);
        HWRITE          : in     vl_logic;
        UARTCLK         : in     vl_logic;
        UART_RXD        : in     vl_logic;
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        fifo_en         : in     vl_logic_vector(1 downto 0);
        number_data_receive: in     vl_logic_vector(3 downto 0);
        number_data_trans: in     vl_logic_vector(3 downto 0);
        parity_bit_mode : in     vl_logic;
        state_isr       : in     vl_logic_vector(1 downto 0);
        stop_bit_twice  : in     vl_logic;
        uart_mode_clk_sel: in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end AHB_APB_UART_vlg_sample_tst;
