`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National Chiao Tung University
// Engineer: Chun-Jen Tsai
//
// Create Date:    14:24:54 11/29/2016 
// Design Name: 
// Module Name:    lab9 
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
module lab9(
  input clk,
  input reset,
  input  button,
  output [7:0] led,
  output LCD_E,
  output LCD_RS,
  output LCD_RW,
  output [3:0] LCD_D,
  input ROT_A,
  input ROT_B
  );

  // declare system variables
wire btn_level, btn_pressed;
wire [20:0] T;
reg prev_btn_level, led_on;
reg [127:0] row_A, row_B;
reg [20:0] cnt;
reg [8:0] f, dc;
wire rot_event;
wire rot_right;

debounce btn_db0(
    .clk(clk),
    .btn_input(button),
    .btn_output(btn_level)
  );

LCD_module lcd0( 
    .clk(clk),
    .reset(reset),
    .row_A(row_A),
    .row_B(row_B),
    .LCD_E(LCD_E),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_D(LCD_D)
  );

Rotation_direction RTD(
    .CLK(clk),
    .ROT_A(ROT_A),
    .ROT_B(ROT_B),
    .rotary_event(rot_event),
    .rotary_right(rot_right)
  );
  
assign led[0] = led_on ? 1 : 0;
assign led[1] = led_on ? 1 : 0;
assign led[2] = led_on ? 1 : 0;
assign led[3] = led_on ? 1 : 0;
assign led[4] = led_on ? 1 : 0;
assign led[5] = led_on ? 1 : 0;
assign led[6] = led_on ? 1 : 0;
assign led[7] = led_on ? 1 : 0;
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1'b1 : 1'b0;
assign T = (f == 25) ? 20000 : 5000;

always @(posedge clk) begin
  if (reset) begin
    prev_btn_level <= 1'b1;
	row_A <= "Frequency:    Hz";
	row_B <= "Duty cycle:    %";
  end
  else begin
    prev_btn_level <= btn_level;
	if(f == 100) row_A[39:16] <= "100";
	else if(f == 25) row_A[39:16] <= " 25";
	if(dc == 0) row_B[31:8] <="  5";
	else if(dc == 1) row_B[31:8] <=" 25";
	else if(dc == 2) row_B[31:8] <=" 50";
	else if(dc == 3) row_B[31:8] <=" 75";
	else if(dc == 4) row_B[31:8] <="100";
  end
end
always @(posedge clk)begin
	if(reset) f <= 100;
	else if(btn_pressed && f == 100) f <= 25;
	else if(btn_pressed && f == 25) f <= 100;
end
always @(posedge clk) begin
	if(reset) dc <= 0;
	else begin
		if(rot_event && rot_right && dc != 4) dc <= dc + 1;
		else if(rot_event && !rot_right && dc) dc <= dc - 1;
	end
end
always @(posedge clk) begin
	if(reset || btn_pressed) begin cnt <= 0; led_on <= 1; end
	else begin
		if(led_on && cnt == T * 5 && !dc) led_on <= 0;
		else if(led_on && cnt == T * (dc * 25) && dc != 4) led_on <= 0;
		else if(!led_on && cnt == T * 100) begin led_on <= 1; cnt <= 0; end
		cnt <= cnt + 1;
	end
end
  
endmodule
