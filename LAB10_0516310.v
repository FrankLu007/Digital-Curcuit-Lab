`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:26:49 12/02/2015 
// Design Name: 
// Module Name:    lab10
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
module lab10(
  input clk,
  input reset,
  output [7:0] led,
  input ROT_A,
  input ROT_B,

  // VGA specific I/O ports
  output VGA_HSYNC,
  output VGA_VSYNC,
  output VGA_RED,
  output VGA_GREEN,
  output VGA_BLUE
  );

  // Declare system variables
  wire rot_event;
  wire rot_right;
  reg [2:0] pos, pix, s;
  reg [9:0] px, py;
  reg [15:0] cnt;

  // declare SRAM control signals
  wire [16:0] sram_addr;
  wire [2:0]  data_in;
  wire [2:0]  data_out;
  wire        we, en;

  // General VGA control signals
  wire video_on;
  wire pixel_tick;  
  wire [9:0] pixel_x; 
  wire [9:0] pixel_y;
  reg  [2:0] rgb_reg;
  reg  [2:0] rgb_next;
  reg  [16:0] dummy_addr;

  // Declare the video buffer size
  localparam VBUF_W = 320; // video buffer width
  localparam VBUF_H = 240; // video buffer height

  // Instiantiate a VGA sync signal generator
  vga_sync vs0(
    .clk(clk), .reset(reset), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
    .visible(video_on), .p_tick(pixel_tick),
    .pixel_x(pixel_x), .pixel_y(pixel_y)
  );

  // Instiantiate a rotary dial controller
  Rotation_direction RTD(
    .CLK(clk),
    .ROT_A(ROT_A),
    .ROT_B(ROT_B),
    .rotary_event(rot_event),
    .rotary_right(rot_right)
  );
	
  sram #(.DATA_WIDTH(3), .ADDR_WIDTH(17), .RAM_SIZE(VBUF_W*VBUF_H+112*40))
    ram0 (.clk(clk), .we(we), .en(en),
            .addr(sram_addr), .data_i(data_in), .data_o(data_out));
assign led = 0;
assign we = (s == 1);
assign en = 1; 
assign sram_addr = dummy_addr;
assign data_in = pix; 
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;


always @(posedge clk) begin
     if (pixel_tick && s == 2) rgb_reg <= rgb_next;
end
always @(*) begin
     if(s == 2 && video_on) rgb_next <= data_out;
	 else rgb_next <= 0;
end
always @(posedge clk)begin
     if (reset)begin
		s <= 0;
		dummy_addr <= 320*240;
		cnt <= 0;
		pos <= 0;
		py <= 8;
		px <= 0;
     end
     else begin
         case (s)
			 3 : s <= 1;
			 4 : s <= 0;
             0 : begin
				if(video_on) begin
				pix <= data_out;
				dummy_addr <= py * VBUF_W + px;
				cnt <= cnt + 1;
				s <= 3;
				end
			 end
			 1 : begin
				if(video_on) begin
				if(cnt != 112*40) dummy_addr <= 320*240 + cnt;
				if(cnt == 112*40+1) begin s <= 2; dummy_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1); end
				else if(px == pos * 32 + 111) begin px <= pos * 32; py <= py + 1; s <= 4; end
				else begin px <= px + 1; s <= 4; end
				end
			 end
			 2 : begin
				if(rot_event) begin
					if(rot_right && pos < 6) begin pos <= pos + 1;px <= pos * 32 + 32;end
					else if(!rot_right && pos) begin pos <= pos - 1; px <= pos * 32 - 32;end
					py <= 8;
					cnt <= 0;
					dummy_addr <= 320*240;
					s <= 4;
				end
				else dummy_addr <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
			 end
		endcase
     end
end
endmodule