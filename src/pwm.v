`timescale 1ns / 1ps

module pwm #(
    parameter PERIOD = 500,      // PWM周期，单位为时钟周期数
    parameter DUTY   = 50        // PWM占空比，单位为时钟周期数
)(
    input  wire clk,             // 时钟信号
    input  wire rst_n,           // 复位信号，低有效
    output reg  pwm_out          // PWM输出
);

reg [$clog2(PERIOD)-1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cnt <= 0;
    else if (cnt == PERIOD - 1)
        cnt <= 0;
    else
        cnt <= cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pwm_out <= 1'b0;
    else if (cnt < DUTY)
        pwm_out <= 1'b1;
    else
        pwm_out <= 1'b0;
end

endmodule