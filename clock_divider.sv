module clock_divider (
    input  logic clk_in,   // Clock đầu vào
    input  logic rst_n,    // Reset tín hiệu âm
    output logic clk_out   // Clock đầu ra (chia 42)
);

    logic [5:0] counter;   // Counter 6-bit để đếm đến 42

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n)
            counter <= 6'b0; // Reset counter về 0
        else if (counter == 6'd41) // Đếm đủ 42 chu kỳ (0 -> 41)
            counter <= 6'b0;
        else
            counter <= counter + 6'b1; // Tăng counter mỗi chu kỳ của clk_in
    end

    // Đảo trạng thái clk_out khi counter đạt giá trị 41
    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n)
            clk_out <= 1'b0; // Reset clk_out về 0
        else if (counter == 6'd41)
            clk_out <= ~clk_out; // Đảo trạng thái clk_out
    end

endmodule
