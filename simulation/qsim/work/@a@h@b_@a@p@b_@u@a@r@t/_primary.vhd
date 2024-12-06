library verilog;
use verilog.vl_types.all;
entity AHB_APB_UART is
    port(
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HWRITE          : in     vl_logic;
        HSIZES          : in     vl_logic_vector(1 downto 0);
        HBURST          : in     vl_logic_vector(2 downto 0);
        HSELABPif       : in     vl_logic;
        HREADYin        : in     vl_logic;
        HWDATA          : in     vl_logic_vector(31 downto 0);
        UARTCLK         : in     vl_logic;
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        parity_bit_mode : in     vl_logic;
        stop_bit_twice  : in     vl_logic;
        number_data_receive: in     vl_logic_vector(3 downto 0);
        number_data_trans: in     vl_logic_vector(3 downto 0);
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        state_isr       : in     vl_logic_vector(1 downto 0);
        uart_mode_clk_sel: in     vl_logic;
        fifo_en         : in     vl_logic_vector(1 downto 0);
        HREADYout       : out    vl_logic;
        HRESP           : out    vl_logic_vector(1 downto 0);
        HRDATA          : out    vl_logic_vector(31 downto 0);
        UART_RXD        : in     vl_logic;
        UART_TXD        : out    vl_logic;
        PADDR           : out    vl_logic_vector(31 downto 0)
    );
end AHB_APB_UART;
