library verilog;
use verilog.vl_types.all;
entity fifo_read_memory_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        fifo_en         : in     vl_logic;
        fifofull        : in     vl_logic;
        notempty        : in     vl_logic;
        rdaddr          : in     vl_logic_vector(4 downto 0);
        read_en         : in     vl_logic;
        rst_n           : in     vl_logic;
        wraddr          : in     vl_logic_vector(4 downto 0);
        write_data      : in     vl_logic_vector(11 downto 0);
        write_en        : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end fifo_read_memory_vlg_sample_tst;
