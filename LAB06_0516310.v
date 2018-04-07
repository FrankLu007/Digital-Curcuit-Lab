`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date:    15:45:54 10/04/2016 
// Design Name: 
// Module Name:    lab5 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This is a sample top module of lab 5: sd card reader.
//              The behavior of this module is as follows:
//              1. The moudle will read one block (512 bytes) of the SD card
//                 into an on-chip SRAM every time the user hit the WEST button.
//              2. The starting address of the disk block is #8192 (i.e., 0x2000).
//              3. A message will be printed on the UART about the block id and the
//                 first byte of the block.
//              4. After printing the message, the block address will be incremented
//                 by one, waiting for the next user button press.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module lab5(
    // General system I/O ports
    input  clk,
    input  reset,
    input  button,
    input  rx,
    output tx,
    output [7:0] led,

    // SD card specific I/O ports
    output cs,
    output sclk,
    output mosi,
    input  miso
    );

// declare system variables
wire btn_pressed;
wire [15:0] mul[0:3];
reg  [0:1047] printdata;
reg  prev_btn_level;
reg  [9:0] sd_counter;
reg  [7:0] out;
reg  [3:0] s, x, y, z;
reg  [0:63] tag;
reg  [31:0] cntA[0:3], cntB[0:3], ans[0:3][0:3];
reg  [15:0] A[0:3][0:3], B[0:3][0:3], num;

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

// declare SD card interface signals
wire clk_sel;
wire clk_500k;
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finish;
wire [7:0] sd_dout;
wire sd_valid;

// declare a SRAM memory block
wire [7:0] data_in;
wire [7:0] data_out;
wire       we, en;
wire [8:0] sram_addr;



debounce btn_db0(
  .clk(clk),
  .btn_input(button),
  .btn_output(btn_level));

uart uart0(
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
  .recv_error(recv_error));

sd_card sd_card0(
  .cs(cs),
  .sclk(sclk),
  .mosi(mosi),
  .miso(miso),

  .clk(clk_sel),
  .rst(reset),
  .rd_req(rd_req),
  .block_addr(rd_addr),
  .init_finish(init_finish),
  .dout(sd_dout),
  .sd_valid(sd_valid));

clk_divider#(100) clk_divider0(
  .clk(clk),
  .rst(reset),
  .clk_out(clk_500k));
  
sram ram0(.clk(clk), .we(we), .en(en),
          .addr(sram_addr), .data_i(data_in), .data_o(data_out));
	  
assign clk_sel = (init_finish)? clk : clk_500k; // clocks for the SD controller
assign led = 8'h00;
assign we = (s == 2) ? sd_valid : 0;     // Write data into SRAM when sd_valid is high.
assign en = 1;             // Always enable the SRAM block.
assign data_in = sd_dout;  // Input data always comes from the SD controller.
assign sram_addr = sd_counter[8:0];// Set the driver of the SRAM address signal.
assign transmit = (s == 7);
assign tx_byte = printdata[num +: 8];
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;
assign mul[0] = cntA[0] * cntB[0];
assign mul[1] = cntA[1] * cntB[1];
assign mul[2] = cntA[2] * cntB[2];
assign mul[3] = cntA[3] * cntB[3];
always @(posedge clk) begin
          printdata[   0: 8*14-1] = "The result is:";
	 printdata[8*14: 8*16-1] = {8'h0D, 8'h0A};
	 printdata[8*16: 8*18-1] = "[ ";
     printdata[8*18: 8*19-1] = (ans[0][0]/4096%16 <= 9) ? ans[0][0]/4096%16 + 48 : ans[0][0]/4096%16 + 55;
     printdata[8*19: 8*20-1] = (ans[0][0]/256%16 <= 9) ? ans[0][0]/256%16 + 48 : ans[0][0]/256%16 + 55;
     printdata[8*20: 8*21-1] = (ans[0][0]/16%16 <= 9) ? ans[0][0]/16%16 + 48 : ans[0][0]/16%16 + 55;
     printdata[8*21: 8*22-1] = (ans[0][0]%16 <= 9) ? ans[0][0]%16 + 48 : ans[0][0]%16 + 55;
     printdata[8*22: 8*24-1] = ", ";
     printdata[8*24: 8*25-1] = (ans[0][1]/4096%16 <= 9) ? ans[0][1]/4096%16 + 48 : ans[0][1]/4096%16 + 55;
     printdata[8*25: 8*26-1] = (ans[0][1]/256%16 <= 9) ? ans[0][1]/256%16 + 48 : ans[0][1]/256%16 + 55;
     printdata[8*26: 8*27-1] = (ans[0][1]/16%16 <= 9) ? ans[0][1]/16%16 + 48 : ans[0][1]/16%16 + 55;
     printdata[8*27: 8*28-1] = (ans[0][1]%16 <= 9) ? ans[0][1]%16 + 48 : ans[0][1]%16 + 55;
     printdata[8*28: 8*30-1] = ", ";
     printdata[8*30: 8*31-1] = (ans[0][2]/4096%16 <= 9) ? ans[0][2]/4096%16 + 48 : ans[0][2]/4096%16 + 55;
     printdata[8*31: 8*32-1] = (ans[0][2]/256%16 <= 9) ? ans[0][2]/256%16 + 48 : ans[0][2]/256%16 + 55;
     printdata[8*32: 8*33-1] = (ans[0][2]/16%16 <= 9) ? ans[0][2]/16%16 + 48 : ans[0][2]/16%16 + 55;
     printdata[8*33: 8*34-1] = (ans[0][2]%16 <= 9) ? ans[0][2]%16 + 48 : ans[0][2]%16 + 55;
     printdata[8*34: 8*36-1] = ", ";
     printdata[8*36: 8*37-1] = (ans[0][3]/4096%16 <= 9) ? ans[0][3]/4096%16 + 48 : ans[0][3]/4096%16 + 55;
     printdata[8*37: 8*38-1] = (ans[0][3]/256%16 <= 9) ? ans[0][3]/256%16 + 48 : ans[0][3]/256%16 + 55;
     printdata[8*38: 8*39-1] = (ans[0][3]/16%16 <= 9) ? ans[0][3]/16%16 + 48 : ans[0][3]/16%16 + 55;
     printdata[8*39: 8*40-1] = (ans[0][3]%16 <= 9) ? ans[0][3]%16 + 48 : ans[0][3]%16 + 55;
     printdata[8*40: 8*42-1] = " ]";
	 printdata[8*42: 8*44-1] = {8'h0D, 8'h0A};
	 printdata[8*44: 8*46-1] = "[ ";
     printdata[8*46: 8*47-1] = (ans[1][0]/4096%16 <= 9) ? ans[1][0]/4096%16 + 48 : ans[1][0]/4096%16 + 55;
     printdata[8*47: 8*48-1] = (ans[1][0]/256%16 <= 9) ? ans[1][0]/256%16 + 48 : ans[1][0]/256%16 + 55;
     printdata[8*48: 8*49-1] = (ans[1][0]/16%16 <= 9) ? ans[1][0]/16%16 + 48 : ans[1][0]/16%16 + 55;
     printdata[8*49: 8*50-1] = (ans[1][0]%16 <= 9) ? ans[1][0]%16 + 48 : ans[1][0]%16 + 55;
     printdata[8*50: 8*52-1] = ", ";
     printdata[8*52: 8*53-1] = (ans[1][1]/4096%16 <= 9) ? ans[1][1]/4096%16 + 48 : ans[1][1]/4096%16 + 55;
     printdata[8*53: 8*54-1] = (ans[1][1]/256%16 <= 9) ? ans[1][1]/256%16 + 48 : ans[1][1]/256%16 + 55;
     printdata[8*54: 8*55-1] = (ans[1][1]/16%16 <= 9) ? ans[1][1]/16%16 + 48 : ans[1][1]/16%16 + 55;
     printdata[8*55: 8*56-1] = (ans[1][1]%16 <= 9) ? ans[1][1]%16 + 48 : ans[1][1]%16 + 55;
     printdata[8*56: 8*58-1] = ", ";
     printdata[8*59: 8*60-1] = (ans[1][2]/4096%16 <= 9) ? ans[1][2]/4096%16 + 48 : ans[1][2]/4096%16 + 55;
     printdata[8*60: 8*61-1] = (ans[1][2]/256%16 <= 9) ? ans[1][2]/256%16 + 48 : ans[1][2]/256%16 + 55;
     printdata[8*61: 8*62-1] = (ans[1][2]/16%16 <= 9) ? ans[1][2]/16%16 + 48 : ans[1][2]/16%16 + 55;
     printdata[8*62: 8*63-1] = (ans[1][2]%16 <= 9) ? ans[1][2]%16 + 48 : ans[1][2]%16 + 55;
     printdata[8*63: 8*65-1] = ", ";
     printdata[8*65: 8*66-1] = (ans[1][3]/4096%16 <= 9) ? ans[1][3]/4096%16 + 48 : ans[1][3]/4096%16 + 55;
     printdata[8*66: 8*67-1] = (ans[1][3]/256%16 <= 9) ? ans[1][3]/256%16 + 48 : ans[1][3]/256%16 + 55;
     printdata[8*67: 8*68-1] = (ans[1][3]/16%16 <= 9) ? ans[1][3]/16%16 + 48 : ans[1][3]/16%16 + 55;
     printdata[8*68: 8*69-1] = (ans[1][3]%16 <= 9) ? ans[1][3]%16 + 48 : ans[1][3]%16 + 55;
     printdata[8*69: 8*71-1] = " ]";
	 printdata[8*71: 8*73-1] = {8'h0D, 8'h0A};
	 printdata[8*73: 8*75-1] = "[ ";
     printdata[8*75: 8*76-1] = (ans[2][0]/4096%16 <= 9) ? ans[2][0]/4096%16 + 48 : ans[2][0]/4096%16 + 55;
     printdata[8*76: 8*77-1] = (ans[2][0]/256%16 <= 9) ? ans[2][0]/256%16 + 48 : ans[2][0]/256%16 + 55;
     printdata[8*77: 8*78-1] = (ans[2][0]/16%16 <= 9) ? ans[2][0]/16%16 + 48 : ans[2][0]/16%16 + 55;
     printdata[8*78: 8*79-1] = (ans[2][0]%16 <= 9) ? ans[2][0]%16 + 48 : ans[2][0]%16 + 55;
     printdata[8*79: 8*81-1] = ", ";
     printdata[8*81: 8*82-1] = (ans[2][1]/4096%16 <= 9) ? ans[2][1]/4096%16 + 48 : ans[2][1]/4096%16 + 55;
     printdata[8*82: 8*83-1] = (ans[2][1]/256%16 <= 9) ? ans[2][1]/256%16 + 48 : ans[2][1]/256%16 + 55;
     printdata[8*83: 8*84-1] = (ans[2][1]/16%16 <= 9) ? ans[2][1]/16%16 + 48 : ans[2][1]/16%16 + 55;
     printdata[8*84: 8*85-1] = (ans[2][1]%16 <= 9) ? ans[2][1]%16 + 48 : ans[2][1]%16 + 55;
     printdata[8*85: 8*87-1] = ", ";
     printdata[8*87: 8*88-1] = (ans[2][2]/4096%16 <= 9) ? ans[2][2]/4096%16 + 48 : ans[2][2]/4096%16 + 55;
     printdata[8*88: 8*89-1] = (ans[2][2]/256%16 <= 9) ? ans[2][2]/256%16 + 48 : ans[2][2]/256%16 + 55;
     printdata[8*89: 8*90-1] = (ans[2][2]/16%16 <= 9) ? ans[2][2]/16%16 + 48 : ans[2][2]/16%16 + 55;
     printdata[8*90: 8*91-1] = (ans[2][2]%16 <= 9) ? ans[2][2]%16 + 48 : ans[2][2]%16 + 55;
     printdata[8*91: 8*93-1] = ", ";
     printdata[8*93: 8*94-1] = (ans[2][3]/4096%16 <= 9) ? ans[2][3]/4096%16 + 48 : ans[2][3]/4096%16 + 55;
     printdata[8*94: 8*95-1] = (ans[2][3]/256%16 <= 9) ? ans[2][3]/256%16 + 48 : ans[2][3]/256%16 + 55;
     printdata[8*95: 8*96-1] = (ans[2][3]/16%16 <= 9) ? ans[2][3]/16%16 + 48 : ans[2][3]/16%16 + 55;
     printdata[8*96: 8*97-1] = (ans[2][3]%16 <= 9) ? ans[2][3]%16 + 48 : ans[2][3]%16 + 55;
     printdata[8*97: 8*99-1] = " ]";
	 printdata[8*99: 8*101-1] = {8'h0D, 8'h0A};
	 printdata[8*101: 8*103-1] = "[ ";
     printdata[8*103: 8*104-1] = (ans[3][0]/4096%16 <= 9) ? ans[3][0]/4096%16 + 48 : ans[3][0]/4096%16 + 55;
     printdata[8*104: 8*105-1] = (ans[3][0]/256%16 <= 9) ? ans[3][0]/256%16 + 48 : ans[3][0]/256%16 + 55;
     printdata[8*105: 8*106-1] = (ans[3][0]/16%16 <= 9) ? ans[3][0]/16%16 + 48 : ans[3][0]/16%16 + 55;
     printdata[8*106: 8*107-1] = (ans[3][0]%16 <= 9) ? ans[3][0]%16 + 48 : ans[3][0]%16 + 55;
     printdata[8*107: 8*109-1] = ", ";
     printdata[8*109: 8*110-1] = (ans[3][1]/4096%16 <= 9) ? ans[3][1]/4096%16 + 48 : ans[3][1]/4096%16 + 55;
     printdata[8*110: 8*111-1] = (ans[3][1]/256%16 <= 9) ? ans[3][1]/256%16 + 48 : ans[3][1]/256%16 + 55;
     printdata[8*111: 8*112-1] = (ans[3][1]/16%16 <= 9) ? ans[3][1]/16%16 + 48 : ans[3][1]/16%16 + 55;
     printdata[8*112: 8*113-1] = (ans[3][1]%16 <= 9) ? ans[3][1]%16 + 48 : ans[3][1]%16 + 55;
     printdata[8*113: 8*115-1] = ", ";
     printdata[8*115: 8*116-1] = (ans[3][2]/4096%16 <= 9) ? ans[3][2]/4096%16 + 48 : ans[3][2]/4096%16 + 55;
     printdata[8*116: 8*117-1] = (ans[3][2]/256%16 <= 9) ? ans[3][2]/256%16 + 48 : ans[3][2]/256%16 + 55;
     printdata[8*117: 8*118-1] = (ans[3][2]/16%16 <= 9) ? ans[3][2]/16%16 + 48 : ans[3][2]/16%16 + 55;
     printdata[8*118: 8*119-1] = (ans[3][2]%16 <= 9) ? ans[3][2]%16 + 48 : ans[3][2]%16 + 55;
     printdata[8*119: 8*121-1] = ", ";
     printdata[8*121: 8*122-1] = (ans[3][3]/4096%16 <= 9) ? ans[3][3]/4096%16 + 48 : ans[3][3]/4096%16 + 55;
     printdata[8*122: 8*123-1] = (ans[3][3]/256%16 <= 9) ? ans[3][3]/256%16 + 48 : ans[3][3]/256%16 + 55;
     printdata[8*123: 8*124-1] = (ans[3][3]/16%16 <= 9) ? ans[3][3]/16%16 + 48 : ans[3][3]/16%16 + 55;
     printdata[8*124: 8*125-1] = (ans[3][3]%16 <= 9) ? ans[3][3]%16 + 48 : ans[3][3]%16 + 55;
     printdata[8*125: 8*127-1] = " ]";
	 printdata[8*127: 8*131-1] = {8'h0D, 8'h0A, 8'h0D, 8'h0A};
end

always @(posedge clk) begin
	if(reset) begin
	rd_addr <= 8192;
	out <= 0;
	sd_counter <= 0;
	s <= 0;
	tag <= 0;
	num <= 0;
	x <= 0;
	y <= 0;
	z <= 0;
	end
	else begin
		case(s)
		0 : 
			if(init_finish) s <= 8;
		8 :
			if(btn_pressed) s <= 1;
		1 :  
			s <= 2;
		2 :
			if(sd_counter == 512) begin s <= 3; sd_counter <= 0; end
			else if(we) sd_counter <= sd_counter + 1;
		3 : begin
			tag[0:55] <= tag[8:63];
			tag[56:63] <= data_out;
			if(tag == "MATX_TAG") s <= 4;
			else if(sd_counter == 512+63) begin s <= 1; sd_counter <= 0; rd_addr <= rd_addr + 1; end
			else sd_counter <= sd_counter + 1;
			end
		4 : begin
			if(z == 2) begin x <= x + 1; z <= 0; num <= 0; A[x][y] <= num; end
			else if(x == 4) begin 
				x <= 0; 
				y <= y + 1; 
				cntA[0] <= A[0][0];
				cntA[1] <= A[0][1];
				cntA[2] <= A[0][2];
				cntA[3] <= A[0][3];
			end
			else if(y == 4) begin s <= 5; y <= 0; sd_counter <= sd_counter + 1; end
			else if((data_out <= 57 && data_out >= 48) ||(data_out >= 65 && data_out <= 70)) begin
				z <= z + 1;
				sd_counter <= sd_counter + 1;			
				if(data_out <= 57) num <= num * 16 + (data_out - 48);
				else num <= num * 16 + (data_out - 55);
			end
			else sd_counter <= sd_counter + 1;
			end
		5 : begin
			if(z == 2) begin x <= x + 1; z <= 0; num <= 0; B[x][y] <= num; end
			else if(x == 4) begin x <= 0; y <= y + 1; end
			else if(y == 4) begin 
				s <= 6; 
				y <= 1;  
				cntB[0] <= B[0][0];
				cntB[1] <= B[1][0];
				cntB[2] <= B[2][0];
				cntB[3] <= B[3][0];
			end
			else if((data_out <= 57 && data_out >= 48) ||(data_out >= 65 && data_out <= 70)) begin
				if(data_out <= 57) num <= num * 16 + data_out - 48;
				else num <= num * 16 + data_out - 55;
				z <= z + 1;
				sd_counter <= sd_counter + 1;
			end
			else sd_counter <= sd_counter + 1;
			end
		6 : begin
			if(x == 4) begin s <= 7; ans[3][3] <= mul[0] + mul[1] + mul[2] + mul[3]; num <= 0; x <= 0; end
			else if(y == 4) begin 
				y <= 0; 
				x <= x + 1; 
			end
			else begin
				if(!y) ans[x-1][3] <= mul[0] + mul[1] + mul[2] + mul[3];
				else ans[x][y-1] <= mul[0] + mul[1] + mul[2] + mul[3];
				cntA[0] <= A[x][0];
				cntA[1] <= A[x][1];
				cntA[2] <= A[x][2];
				cntA[3] <= A[x][3];
				cntB[0] <= B[0][y];
				cntB[1] <= B[1][y];
				cntB[2] <= B[2][y];
				cntB[3] <= B[3][y];
				y <= y + 1;
			end
			end
		7 : begin
			//if(!is_transmitting) begin
			if(num < 1048 && !is_transmitting) num <= num + 8;
			else if(num >= 1048) begin 
				s <= 8; 
				sd_counter <= sd_counter + 1;
				y <= 0; x <= 0; z <= 0;  
				num <= 0;
				tag <= 0;
				end
			/*if(x == 4) begin 
				x <= 0; 
				y <= y + 1; 
			end
			else if(y == 4) begin s <= 8; y <= 0;end
			else begin
				x <= x + 1;
				if(A[x][y][7:0] > 9) out <= A[x][y][7:0]+55;
				else out <= A[x][y][7:0]+48;
			end*/
			//end
		end
		endcase
	end
end

always @(posedge clk) begin
  if (reset)
    prev_btn_level <= 0;
  else
    prev_btn_level <= btn_level;
end
always @(*) begin
	 rd_req <= (s == 1);
end

endmodule