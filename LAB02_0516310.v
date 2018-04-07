`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:17:19 10/01/2016 
// Design Name: 
// Module Name:    lab2 
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
module lab2(
    input clk,
    input reset,
    input btn_W,
    input btn_E,
    output [7:0] led
    );
	 reg [8:0] temW;
	 reg [8:0] temE;
	 reg signed[3:0] cnt = 0;
	 

	always @(posedge clk) begin
		if(reset) cnt <= 0;	
		
		else if(temW == 9'b011111111 && cnt < 7) cnt <= cnt+1;
		else if(temE == 9'b011111111 && cnt > -8) cnt <= cnt-1;
		
	end
	
	always @(posedge clk) begin
	
   temW <= temW << 1;
	
   if(btn_W) temW[0] <= 1;
	else temW[0] <= 0;			
	
	end
	
	always @(posedge clk) begin
	
	temE <= temE << 1;
	
	if(btn_E) temE[0] <= 1;
	else temE[0] <= 0;
	
	end
	
	assign led[0] = cnt[0];
	assign led[1] = cnt[1];
	assign led[2] = cnt[2];
	assign led[3] = cnt[3];
	assign led[4] = cnt[3];
	assign led[5] = cnt[3];
	assign led[6] = cnt[3];
	assign led[7] = cnt[3];
	
endmodule
