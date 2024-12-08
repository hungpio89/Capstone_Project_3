module priority_selector #(
    parameter NUM_INPUTS = 4,       // Number of input sources
    parameter DATA_WIDTH = 8       // Width of the data signals
) (
    input  logic [NUM_INPUTS-1:0] req,           // Request signals from sources
    input  logic [DATA_WIDTH-1:0] data_in [NUM_INPUTS-1:0], // Data from sources
    output logic [DATA_WIDTH-1:0] data_out,     // Selected data for transmission
    output logic [$clog2(NUM_INPUTS)-1:0] grant // Index of granted request
);
    // Internal priority encoder logic
    integer i;
    always_comb begin
        grant = '0;               // Default: no grant
        data_out = '0;            // Default: no data
        for (i = 0; i < NUM_INPUTS; i++) begin
            if (req[i]) begin
                grant = i;        // Grant the highest-priority request
                data_out = data_in[i];
                break;            // Stop at the highest priority
            end
        end
    end
endmodule
