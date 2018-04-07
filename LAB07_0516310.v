`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:47 11/22/2015 
// Design Name: 
// Module Name:    lcd 
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
module lab7(
    input clk,
    input reset,
    input  button,
    output LCD_E,
    output LCD_RS,
    output LCD_RW,
    output [3:0]LCD_D
    );

wire btn_level, btn_pressed;
reg  prev_btn_level;
reg [127:0] row_A, row_B;
reg [15:0] NA, NB, NC;
reg [3:0] s;
reg [0:127] printdata;
reg [30:0] cycle;

// declare a SRAM memory block
wire [15:0] data_in;
wire [15:0] data_out;
wire       we, en;
reg [8:0] ad_counter;

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
   
sram ram0(.clk(clk), .we(we), .en(en),
          .addr(ad_counter), .data_i(data_in), .data_o(data_out));
   
assign btn_pressed = (btn_level & !prev_btn_level);    
assign en = 1;
assign we = (s < 3);
assign data_in = NC;

always @(ad_counter) begin
	if(reset) printdata <= "Fibo #00 is 0000";
	else if(s > 2)begin
		printdata[ 48: 55] <= (ad_counter > 15) ?  49 : 48;
		printdata[ 56: 63] <= (ad_counter %16 > 9) ? ad_counter%16 + 55 : ad_counter%16 + 48;
		printdata[ 96:103] <= (data_out/4096%16 > 9) ? data_out/4096%16 + 55 : data_out/4096%16 + 48;
		printdata[104:111] <= (data_out/256%16 > 9) ? data_out/256%16 + 55 : data_out/256%16 + 48;
		printdata[112:119] <= (data_out/16%16 > 9) ? data_out/16%16 + 55 : data_out/16%16 + 48;
		printdata[120:127] <= (data_out%16 > 9) ? data_out%16 + 55 : data_out%16 + 48;
	end
end

always @(posedge clk) begin
	if(reset) begin
		NA <= 0;
		NB <= 1;
		NC <= 0;
		ad_counter <= 1;
		s <= 0;
		row_A <= "Fibo #01 is 0000";
		row_B <= "Fibo #02 is 0001";
	end
	else begin
		case(s)
		0 :begin
			NC <= 1;
			ad_counter <= 2;
			s <= 1;
		end
		1 : begin
			ad_counter <= 3;
			NC <= NA + NB;
			NA <= 1;
			s <= 2;
		end
		2 : begin
			NC <= NA + NB;
			NA <= NB;
			NB <= NA + NB;
			if(ad_counter == 26) begin
				s <= 5;
				ad_counter <= 3;
			end
			else ad_counter <= ad_counter + 1;
		end
		3 : begin		
				row_A <= row_B;
				row_B <= printdata;
				s <= 5;
				cycle <= 0;
			if(ad_counter < 25) ad_counter <= ad_counter + 1;
			else ad_counter <= 1;
		end
		5 : begin
			cycle <= cycle + 1;
			if(cycle >= 35000000) s <= 3;
			if(btn_pressed) begin 
				s <= 6; 
				if(ad_counter == 1) ad_counter <= 24;
				else if(ad_counter == 2) ad_counter <= 25;
				else ad_counter <= ad_counter - 2; 
				cycle <= 0; 
				row_A <= row_B; 
				row_B <= printdata;
				end
		end
		4 : begin
				row_A <= printdata;
				row_B <= row_A;
				s <= 6;
				cycle <= 0;
			if(ad_counter > 1) ad_counter <= ad_counter - 1;
			else ad_counter <= 25;
		end
		6 : begin
			cycle <= cycle + 1;
			if(cycle >= 35000000) s <= 4;
			if(btn_pressed) begin 
				s <= 3; 
				if(ad_counter == 25) ad_counter <= 2;
				else if(ad_counter == 24) ad_counter <= 1;
				else ad_counter <= ad_counter + 2; 
				cycle <= 0; 
				row_A <= printdata; 
				row_B <= row_A;
				end
		end
		endcase
	end
end

always @(posedge clk) begin
	if (reset)
		prev_btn_level <= 1;
    else
        prev_btn_level <= btn_level;
    end

    
endmodule
