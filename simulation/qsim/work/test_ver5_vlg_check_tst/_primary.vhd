library verilog;
use verilog.vl_types.all;
entity test_ver5_vlg_check_tst is
    port(
        PRDATA          : in     vl_logic_vector(31 downto 0);
        PREADY          : in     vl_logic;
        RXdone          : in     vl_logic;
        RXen            : in     vl_logic;
        TXdone          : in     vl_logic;
        baud_tick       : in     vl_logic;
        cd              : in     vl_logic_vector(12 downto 0);
        ctrl            : in     vl_logic_vector(6 downto 0);
        ctrl_rx_buffer  : in     vl_logic;
        ctrl_shift_register_rd: in     vl_logic_vector(3 downto 0);
        data_is_avail   : in     vl_logic;
        data_is_ready   : in     vl_logic;
        data_is_received: in     vl_logic;
        data_trans      : in     vl_logic_vector(11 downto 0);
        error_rx_detect : in     vl_logic;
        fifo_wr_ctrl    : in     vl_logic;
        parity_bit_rx   : in     vl_logic;
        read_data       : in     vl_logic_vector(7 downto 0);
        rx_fifo_full    : in     vl_logic;
        rx_fifo_mid     : in     vl_logic_vector(7 downto 0);
        rx_not_empty    : in     vl_logic;
        rx_ptr_addr_rd_o: in     vl_logic_vector(4 downto 0);
        rx_ptr_addr_wr_i: in     vl_logic_vector(4 downto 0);
        rx_read_en      : in     vl_logic;
        rx_write_en     : in     vl_logic;
        start_bit_rx    : in     vl_logic;
        stop_bit_rx     : in     vl_logic;
        temp_rx         : in     vl_logic_vector(11 downto 0);
        temp_rx_1       : in     vl_logic_vector(11 downto 0);
        timeout_flag    : in     vl_logic;
        transfer        : in     vl_logic;
        uart_run_flag   : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end test_ver5_vlg_check_tst;
