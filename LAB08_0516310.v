`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date:    11:26:45 11/23/2016 
// Design Name: 
// Module Name:    lab8 
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
module lab8(
  input clk,
  input reset,
  input button,
  output [7:0] led,
  output LCD_E,
  output LCD_RS,
  output LCD_RW,
  output [3:0] LCD_D
  );

// declare system variables
wire btn_level, btn_pressed;
reg prev_btn_level;
reg [0:127] row_A, row_B;
reg [15:0]  pixel_addr, x, num;
reg [3:0]   s;
wire signed [10:0] res;
reg signed [10:0] f[4:0];

// declare SRAM control signals
wire [13:0] sram_addr;
wire [7:0]  data_in;
wire [7:0]  data_out;
wire        we, en;

assign led = {0};

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
  
  debounce btn_db0(
    .clk(clk),
    .btn_input(button),
    .btn_output(btn_level)
  );

  // ------------------------------------------------------------------------
  // The following code describes an initialized SRAM memory block that
  // stores an 160x90 8-bit graylevel image.
  sram ram0(.clk(clk), .we(we), .en(en),
            .addr(sram_addr), .data_i(data_in), .data_o(data_out));

assign we = 0; // Make the SRAM read-only.
assign en = 1; // Always enable the SRAM block.
assign sram_addr = pixel_addr[13:0];
assign data_in = 8'b0; // SRAM is read-only so we tie inputs to zeros.
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1'b1 : 1'b0;
assign res = f[4] + f[3] * 2 + f[1] * (-2) + f[0] * (-1);

always @(posedge clk) begin
	if(reset) begin
		row_A <= "Press WEST to do";
		row_B <= "edge detection..";
	end
	else if(s > 2) begin
		row_A <= "The edge pixel  ";
		row_B <= "  number is     ";
		row_B[ 96: 103] <= (num/4096 > 9) ? num/4096 + 55 : num/4096 + 48;
		row_B[104: 111] <= (num/256%16 > 9) ? num/256%16 + 55 : num/256%16 + 48;
		row_B[112: 119] <= (num/16%16 > 9) ? num/16%16 + 55 : num/16%16 + 48;
		row_B[120: 127] <= (num%16 > 9) ? num%16 + 55 : num%16 + 48;
	end
end

always @(posedge clk) begin
	if(reset) begin
		s <= 0;
		pixel_addr <= 160-2;
		num <= 0;
		x <= 0;
	end
	else begin
		case(s)
		0 : if(btn_pressed) s <= 1;
		1 : begin
			if(x == 5) s <= 2;
			else begin
				f[4-x] <= data_out;
				x <= x + 1;
				pixel_addr <= pixel_addr + 1;
			end
		end
		2 : begin
			if(res > 200 || res < -200) num <= num + 1;
			if(pixel_addr == 160*89+2) s <= 3;
			else begin
				f[4] <= f[3];
				f[3] <= f[2];
				f[2] <= f[1];
				f[1] <= f[0];
				f[0] <= data_out;
				pixel_addr <= pixel_addr + 1;
			end
		end
		endcase
	end
end

always @(posedge clk) begin
  if (reset)
    prev_btn_level <= 1'b1;
  else
    prev_btn_level <= btn_level;
end

endmodule