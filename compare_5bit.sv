module compare_5bit (
    input  logic [5:0] A,
    input  logic [5:0] B,
    output logic       A_less_B
);
    logic [5:0] xor_result;
    logic       result;

    // XOR to detect bit differences
    assign xor_result = A ^ B;

    // Determine if A < B
    always_comb begin
        result = 0;
        for (int i = 5; i >= 0; i--) begin
            if (xor_result[i]) begin
                result = (A[i] < B[i]); // Compare first differing bit
                break;                  // Exit loop after first difference
            end
        end
        A_less_B = result;
    end
endmodule
