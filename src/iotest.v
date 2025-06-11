`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/06 21:10:54
// Design Name: 
// Module Name: iotest
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 边沿检测模块
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module iotest(
    input  wire clk,      // 时钟信号
    input  wire rst_n,    // 复位信号，低有效
    input  wire din,      // 输入信号
    output wire pos_edge, // 上升沿检测输出
    output wire neg_edge  // 下降沿检测输出
);

reg din_d; // 输入信号的延迟一拍

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        din_d <= 1'b0;
    else
        din_d <= din;
end

assign pos_edge =  din & ~din_d; // 上升沿检测
assign neg_edge = ~din &  din_d; // 下降沿检测

endmodule
