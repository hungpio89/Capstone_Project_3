module clock_generator_40us (
    input  logic clk_in,   // Clock đầu vào (50 MHz)
    input  logic rst_n,    // Reset tín hiệu âm
    output logic clk_out   // Clock đầu ra (40 µs)
);

    logic [10:0] counter;  // Counter 11-bit để đếm đến 1999

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n)
            counter <= 11'b0; // Reset counter về 0
        else if (counter == 11'd1999) // Đếm đủ 2000 chu kỳ
            counter <= 11'b0;
        else
            counter <= counter + 11'b1; // Tăng counter mỗi chu kỳ của clk_in
    end

    // Đảo trạng thái clk_out khi counter đạt giá trị 1999
    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n)
            clk_out <= 1'b0; // Reset clk_out về 0
        else if (counter == 11'd1999)
            clk_out <= ~clk_out; // Đảo trạng thái clk_out
    end

endmodule
