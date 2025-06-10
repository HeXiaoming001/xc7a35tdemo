`timescale 1ns / 1ps

module led_blink(
    input  wire clk,      // 时钟信号
    input  wire rst_n,    // 复位信号，低有效
    output reg  led       // LED输出
);

parameter CNT_MAX = 24'd9_999_999; // 计数最大值，假设时钟为10MHz，0.5s翻转一次

reg [23:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 24'd0;
        led <= 1'b0;
    end else begin
        if (cnt < CNT_MAX)
            cnt <= cnt + 1'b1;
        else begin
            cnt <= 24'd0;
            led <= ~led;
        end
    end
end

endmodule