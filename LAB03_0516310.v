`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:42:13 10/07/2016 
// Design Name: 
// Module Name:    hw3_0516310 
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
module hw3_0516310(
   input clk,
	input enable,
	input [79:0] inbits,
	output reg [34:0] out_text = 0,
	output reg valid = 0);
	
	reg [12:0] cnt = 0;
	reg [2:0] num = 0;
	reg [6:0] A = 65;
	reg [79:0] in_bits;
	reg start = 1, Include = 1;
	
	always @(posedge clk) begin
		if(enable) begin
			if(~valid) begin
				if(Include) begin in_bits = inbits; Include = 0; end
				
				if(start) begin
					if(in_bits[79]) start = 0;
					else in_bits = in_bits << 1;
				end

				if(in_bits[79:77] == 0 && ~Include && ~start) begin
					out_text  = out_text << 7;
					case(cnt)
						13'b10111 : out_text[6:0] = A;
						13'b111010101 : out_text[6:0] = A+1;
						13'b11101011101 : out_text[6:0] = A+2;
						13'b1110101 : out_text[6:0] = A+3;
						13'b1 : out_text[6:0] = A+4;
						13'b101011101 : out_text[6:0] = A+5;
						13'b111011101 :out_text[6:0] = A+6;
						13'b1010101 : out_text[6:0] = A+7;
						13'b101 : out_text[6:0] = A+8;
						13'b1011101110111 : out_text[6:0] = A+9;
						13'b111010111 : out_text[6:0] = A+10;
						13'b101110101 : out_text[6:0] = A+11;
						13'b1110111 : out_text[6:0] = A+12;
						13'b11101 : out_text[6:0] = A+13;
						13'b11101110111 : out_text[6:0] = A+14;
						13'b10111011101 : out_text[6:0] = A+15;
						13'b1110111010111 : out_text[6:0] = A+16;
						13'b1011101 : out_text[6:0] = A+17;
						13'b10101 : out_text[6:0] = A+18;
						13'b111 : out_text[6:0] = A+19;
						13'b1010111 : out_text[6:0] = A+20;
						13'b101010111 : out_text[6:0] = A+21;
						13'b101110111 : out_text[6:0] = A+22;
						13'b11101010111 : out_text[6:0] = A+23;
						13'b1110101110111 : out_text[6:0] = A+24;
						13'b11101110101 : out_text[6:0] = A+25;
					endcase
					num = num+1;
					cnt = 0;
					in_bits = in_bits << 3;
					end
					else if(~Include && ~start){cnt, in_bits} = {cnt, in_bits} << 1;
				
					if(num == 5) valid = 1;
			end
		end
		else begin 
			num = 0;
			cnt = 0;
			Include = 1;
			start = 1;
			valid = 0;
			out_text = 0;
		end
	end
	
endmodule
