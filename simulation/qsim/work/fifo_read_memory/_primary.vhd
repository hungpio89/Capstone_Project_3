library verilog;
use verilog.vl_types.all;
entity fifo_read_memory is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        write_en        : in     vl_logic;
        read_en         : in     vl_logic;
        write_data      : in     vl_logic_vector(11 downto 0);
        wraddr          : in     vl_logic_vector(4 downto 0);
        rdaddr          : in     vl_logic_vector(4 downto 0);
        fifofull        : in     vl_logic;
        notempty        : in     vl_logic;
        fifo_en         : in     vl_logic;
        read_data       : out    vl_logic_vector(11 downto 0)
    );
end fifo_read_memory;
