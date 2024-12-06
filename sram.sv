module sram #(
    parameter DATA_WIDTH = 32,       // Data width
    parameter ADDR_WIDTH = 10,       // Address width (2^ADDR_WIDTH entries)
    parameter NUM_BANKS = 4          // Number of memory banks
)(
    // AHB-Lite Interface Signals
    input  logic                  HCLK,        // AHB clock
    input  logic                  HRESETn,     // AHB active-low reset
    input  logic [ADDR_WIDTH-1:0] HADDR,       // Address
    input  logic                  HWRITE,      // Write control signal
    input  logic [1:0]            HTRANS,      // Transfer type
    input  logic [2:0]            HBURST,      // Burst type
    input  logic [2:0]            HSIZE,       // Transfer size (byte, halfword, word)
    input  logic                  HSEL,        // Select signal
    input  logic                  HREADY,      // Ready signal
    input  logic [DATA_WIDTH-1:0] HWDATA,      // Write data
    output reg  [DATA_WIDTH-1:0]  HRDATA,      // Read data
    output reg                   HREADYOUT,    // Ready output signal
    output logic                  ecc_error    // ECC error detection signal
);

    // Internal parameters
    localparam BANK_ADDR_WIDTH = ADDR_WIDTH - $clog2(NUM_BANKS); // Address bits per bank
    localparam ECC_WIDTH = $clog2(DATA_WIDTH + 1);              // Number of ECC bits (Hamming SEC-DED)

    // Memory array: NUM_BANKS banks, each containing 2^(ADDR_WIDTH-log2(NUM_BANKS)) words
    logic [DATA_WIDTH + ECC_WIDTH - 1:0] mem_array [0:NUM_BANKS-1][0:(1<<BANK_ADDR_WIDTH)-1];

    // Internal signals
    logic [$clog2(NUM_BANKS)-1:0] bank_sel;    // Bank select signal
    logic [ADDR_WIDTH-1:0] address_reg;        // Registered address
    logic [DATA_WIDTH-1:0] data_reg;           // Registered write data
    logic write_enable;                        // Write enable for memory
    logic valid_transfer;                      // Valid AHB transaction
    logic ecc_err_internal;                    // Internal ECC error signal
    logic [3:0] burst_count;                       // Burst counter

    // Determine the bank select based on higher address bits
    assign bank_sel = HADDR[ADDR_WIDTH-1:ADDR_WIDTH-$clog2(NUM_BANKS)];

    // AHB-Lite valid transfer: NONSEQ or SEQ transfers with HSEL and HREADY high
    assign valid_transfer = HSEL && HREADY && (HTRANS[1] == 1'b1);

    // Write enable logic
    assign write_enable = valid_transfer && HWRITE;

    // ECC encode function
    function [DATA_WIDTH + ECC_WIDTH - 1:0] encode_ecc(input [DATA_WIDTH-1:0] data);
        integer i, parity;
        logic [DATA_WIDTH + ECC_WIDTH - 1:0] encoded;
        begin
            // Copy data into encoded
            encoded[DATA_WIDTH-1:0] = data;
            // Calculate parity bits
            for (i = 0; i < ECC_WIDTH; i++) begin
                parity = 0;
                for (int j = 0; j < DATA_WIDTH; j++) begin
                    if ((j + 1) & (1 << i)) begin
                        parity ^= data[j];
                    end
                end
                encoded[DATA_WIDTH + i] = parity;
            end
            encode_ecc = encoded;
        end
    endfunction

    // ECC decode function
    function [DATA_WIDTH-1:0] decode_ecc(input [DATA_WIDTH + ECC_WIDTH - 1:0] data_with_ecc, output logic error_detected);
        integer i, parity;
        logic [ECC_WIDTH-1:0] syndrome;
        begin
            error_detected = 0;
            syndrome = 0;

            // Calculate syndrome (indicates error position if non-zero)
            for (i = 0; i < ECC_WIDTH; i++) begin
                parity = 0;
                for (int j = 0; j < DATA_WIDTH + ECC_WIDTH; j++) begin
                    if ((j + 1) & (1 << i)) begin
                        parity ^= data_with_ecc[j];
                    end
                end
                syndrome[i] = parity;
            end

            if (syndrome != 0) begin
                error_detected = 1;
            end

            // Decode the data
            decode_ecc = data_with_ecc[DATA_WIDTH-1:0];
        end
    endfunction

    // AHB-Lite SRAM operation
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HRDATA <= {DATA_WIDTH{1'b0}};
            HREADYOUT <= 1'b1;
            ecc_error <= 1'b0;
            burst_count <= 4'b0;
        end else if (valid_transfer) begin
            HREADYOUT <= 1'b0; // SRAM is busy

            case (HBURST)
                3'b000: burst_count <= 4'h1;       // Single transfer
                3'b001: burst_count <= 4'h4;       // Incremental
                3'b010: burst_count <= 4'h8;       // Wrap burst
                default: burst_count <= 4'h1;      // Default single transfer
            endcase

            if (write_enable) begin
                // Write operation: Store data with ECC
                for (int i = 0; i < burst_count; i++) begin
                    mem_array[bank_sel][HADDR[BANK_ADDR_WIDTH-1:0] + i] <= encode_ecc(HWDATA);
                end
            end else begin
                // Read operation: Retrieve data and decode ECC
                HRDATA <= decode_ecc(mem_array[bank_sel][HADDR[BANK_ADDR_WIDTH-1:0]], ecc_err_internal);
                ecc_error <= ecc_err_internal;
            end

            HREADYOUT <= 1'b1; // SRAM is ready
        end else begin
            HREADYOUT <= 1'b1; // SRAM idle
        end
    end
endmodule
