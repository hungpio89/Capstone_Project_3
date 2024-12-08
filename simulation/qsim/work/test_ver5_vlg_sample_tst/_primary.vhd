library verilog;
use verilog.vl_types.all;
entity test_ver5_vlg_sample_tst is
    port(
        PADDR           : in     vl_logic_vector(11 downto 0);
        PCLK            : in     vl_logic;
        PENABLE         : in     vl_logic;
        PRESETn         : in     vl_logic;
        PSEL            : in     vl_logic;
        PWRITE          : in     vl_logic;
        UARTCLK         : in     vl_logic;
        UART_RXD        : in     vl_logic;
        ctrl_i          : in     vl_logic_vector(6 downto 0);
        desired_baud_rate: in     vl_logic_vector(19 downto 0);
        number_data_receive: in     vl_logic_vector(3 downto 0);
        parity_bit_mode : in     vl_logic;
        state_isr       : in     vl_logic_vector(1 downto 0);
        stop_bit_twice  : in     vl_logic;
        uart_mode_clk_sel: in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end test_ver5_vlg_sample_tst;
