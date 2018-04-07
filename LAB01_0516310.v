`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:15:39 09/26/2016 
// Design Name: 
// Module Name:    HW 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module HW(clk, enable, A, B, C);
	input clk, enable;
	input [7:0] A, B;
	output reg [15:0] C = 0;
	reg [15:0] ans = 0;
	reg [15:0] b = 0;
	reg start = 0;
	reg [3:0] cnt = 0;
	always @(posedge clk) begin
	if(enable) begin
		if(start == 0) begin
			b <= B;
			start <= 1;
		end
		if(cnt < 9 && A[cnt-1] == 1) C <= C + b;
		b = b << 1;
		cnt <= cnt + 1;
	end
	end
	
endmodule
