`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date:    06:30:08 10/03/2016 
// Design Name: 
// Module Name:    lab4 
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
module lab4(
    input clk,
    input reset,
    input rx,
    output tx,
    output [7:0] led
    );

wire [7:0] data[0:65];
reg print = 1, cnt = 0, read = 0, num = 0;
reg [8:0] pcnt = 0;
reg [2:0] anscnt = 0;
reg [7:0] out = 0;
reg [16:0] tmp = 0;
reg [7:0] ans[3:0];
reg [15:0] ini_cnt = 0;

wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

assign led = { 8'b0 }; 
assign tx_byte = out;
assign transmit = print == 1 ? 1 : 0;

uart uart(
    .clk(clk),
    .rst(reset),
    .rx(rx),
    .tx(tx),
    .transmit(transmit),
    .tx_byte(tx_byte),
    .received(received),
    .rx_byte(rx_byte),
    .is_receiving(is_receiving),
    .is_transmitting(is_transmitting),
    .recv_error(recv_error)
    );

assign data[ 0] = 8'd69;//Enter a decimal number: 
assign data[ 1] = 8'd110;
assign data[ 2] = 8'd116;
assign data[ 3] = 8'd101;
assign data[ 4] = 8'd114;
assign data[ 5] = 8'd32;
assign data[ 6] = 8'd97;
assign data[ 7] = 8'd32;
assign data[ 8] = 8'd100;
assign data[ 9] = 8'd101;
assign data[10] = 8'd99;
assign data[11] = 8'd105;
assign data[13] = 8'd97;
assign data[14] = 8'd108; 
assign data[15] = 8'd32;
assign data[16] = 8'd110;
assign data[17] = 8'd117;
assign data[18] = 8'd109;
assign data[19] = 8'd98;
assign data[20] = 8'd101;
assign data[21] = 8'd114;
assign data[22] = 8'd58;
assign data[23] = 8'd32;

assign data[28] = 8'd10;//\nThe hexadecimal number is:
assign data[29] = 8'd13;
assign data[30] = 8'd84;
assign data[31] = 8'd104;
assign data[32] = 8'd101;
assign data[33] = 8'd32;
assign data[34] = 8'd104;
assign data[35] = 8'd101;
assign data[36] = 8'd120;
assign data[37] = 8'd97;
assign data[38] = 8'd100;
assign data[39] = 8'd101;
assign data[40] = 8'd99;
assign data[41] = 8'd105;
assign data[42] = 8'd109;
assign data[43] = 8'd97;
assign data[44] = 8'd108;
assign data[45] = 8'd32;
assign data[46] = 8'd110;
assign data[47] = 8'd117;
assign data[48] = 8'd109;
assign data[49] = 8'd98;
assign data[50] = 8'd101;
assign data[51] = 8'd114;
assign data[52] = 8'd32;
assign data[53] = 8'd105;
assign data[54] = 8'd115;
assign data[55] = 8'd58;
assign data[56] = 8'd32;

assign data[61] = 8'd10;//\n\n
assign data[62] = 8'd13;
assign data[63] = 8'd10;
assign data[64] = 8'd13;

always @(posedge clk) begin
	if(reset) begin 
		print = 1;
		cnt = 0;
		pcnt = 0;
		read = 0;
		tmp = 0;
		anscnt = 0;
		num = 0;
		ini_cnt = 0;
	end
	else if(ini_cnt < 5000) ini_cnt = ini_cnt + 1;
	else begin
		if(print && read) print = 0;
		else if(print && !cnt && !is_transmitting) begin
			out = data[pcnt];
			pcnt = pcnt + 1;
			if(pcnt == 24) begin print = 0;read = 1;pcnt = 28; end
		end
		else if(print && cnt && !is_transmitting) begin
			if(pcnt < 57 || (pcnt > 60 && pcnt < 65)) begin
				out = data[pcnt];
				pcnt = pcnt + 1;
				if(pcnt == 65) begin
					print = 1;
					cnt = 0;
					pcnt = 0;
					read = 0;
					tmp = 0;
					num = 0;
					anscnt = 0;
				end
			end
			else begin
				if(anscnt > 0) begin
					anscnt = anscnt - 1;
					out = ans[anscnt];
					if(anscnt == 0) pcnt = 61;
				end
			end
		end
		else if(read) begin
			rx_temp = received ? rx_byte : 0;
			if(rx_temp >= 48 && rx_temp <= 57 && !is_transmitting) begin 
				print = 1;
				out = rx_temp;
				tmp = tmp * 10 + rx_temp - 48;
				num = num + 1;
			end
			else if(rx_temp == 8'h0D && num) begin read = 0; print = 0; end
		end
		else if(!print && !read && !cnt) begin
			if(tmp%16 > 9) ans[anscnt] = tmp % 16 + 55;
			else ans[anscnt] = tmp % 16 + 48;
			anscnt = anscnt + 1;
			tmp = tmp / 16;
			if(tmp == 0)  begin cnt = 1; print = 1; out = 0;end
		end
	end
end

endmodule