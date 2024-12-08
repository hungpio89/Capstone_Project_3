library verilog;
use verilog.vl_types.all;
entity fifo_read_memory_vlg_check_tst is
    port(
        read_data       : in     vl_logic_vector(11 downto 0);
        sampler_rx      : in     vl_logic
    );
end fifo_read_memory_vlg_check_tst;
