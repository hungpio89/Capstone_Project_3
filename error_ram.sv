module error_ram (
    input  logic        clk,           // Clock signal
    input  logic        rst_n,         // Active low reset
    input  logic        write_enable,  // Write enable signal
    input  logic [31:0] write_address, // Address to write
    input  logic [9:0]  write_error,   // Error code to write
    input  logic        read_enable,   // Read enable signal
    input  logic [31:0] read_address,  // Address to read
    output logic [9:0]  read_error     // Error code read
);

    // Parameters
    parameter DEPTH = 1024;            // Depth of the RAM (number of entries)

    // Memory declaration
    typedef struct packed {
        logic [31:0] address;          // 32-bit address
        logic [9:0]  error;            // 10-bit error code
    } ram_entry_t;

    ram_entry_t ram [0:DEPTH-1];       // RAM array

    // Temporary storage for read operation
    logic [9:0] error_out;
    logic       valid_read;

    // Reset logic to initialize RAM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < DEPTH; i = i + 1) begin
                ram[i].address <= 32'b0;
                ram[i].error   <= 10'b0;
            end
        end else if (write_enable) begin
            // Write logic
            for (int i = 0; i < DEPTH; i = i + 1) begin
                if (ram[i].address == 0 || ram[i].address == write_address) begin
                    ram[i].address <= write_address;
                    ram[i].error   <= write_error;
                    break;
                end
            end
        end
    end

    // Read logic
    always_ff @(posedge clk) begin
        if (read_enable) begin
            valid_read = 0;
            for (int i = 0; i < DEPTH; i = i + 1) begin
                if (ram[i].address == read_address) begin
                    error_out = ram[i].error;
                    valid_read = 1;
                    break;
                end
            end
            if (!valid_read) begin
                error_out = 10'b0; // Return 0 if no match found
            end
        end else begin
            error_out = 10'b0;
        end
    end

    // Output the read error code
    assign read_error = error_out;

endmodule
