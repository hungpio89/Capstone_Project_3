module DIVIDER(
    input logic [31:0] dividend,
    input logic [31:0] divisor,
    output logic [31:0] quotient,
    output logic [31:0] remainder
);
    logic [31:0] temp_dividend;
    logic [31:0] temp_divisor;
    logic [31:0] temp_quotient;
    logic [5:0] count;  // 6 bits to count from 0 to 32

    always_comb begin
        temp_dividend = dividend;
        temp_divisor = divisor;
        temp_quotient = 32'b0;
        count = 32;

        if (divisor == 0) begin
            // Handle division by zero
            temp_quotient = 32'hFFFFFFFF;  // Indicate an error (this is just an example)
            remainder = dividend;          // Dividend as remainder
        end else begin
            while (count > 0) begin
                temp_quotient = temp_quotient << 1;
                if (temp_dividend >= temp_divisor) begin
                    temp_dividend = temp_dividend - temp_divisor;
                    temp_quotient[0] = 1;
                end
                temp_divisor = temp_divisor >> 1;
                count = count - 1;
            end
            remainder = temp_dividend;
        end
        quotient = temp_quotient;
    end
endmodule
