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
wire btn_level, btn_pressed;
reg  print, read, load = 0, check, w = 1;
reg  [6:0] ck_counter, p_counter, x, y;
reg  [9:0] sd_counter;
reg  [7:0] byte0, out = 65;
reg  [31:0] blk_addr = 8192;
reg  [7:0] data [0:8][0:3];
reg  [7:0] test [0:7];
wire  [7:0] printdata [0:85];

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
//assign we = !load ? sd_valid : 0;     // Write data into SRAM when sd_valid is high.
assign en = 1;             // Always enable the SRAM block.
assign data_in = sd_dout;  // Input data always comes from the SD controller.
assign sram_addr = sd_counter[8:0];// Set the driver of the SRAM address signal.
assign tx_byte = out;
assign we = w;
assign printdata[0] = 84;
assign printdata[1] = 104;
assign printdata[2] = 101;
assign printdata[3] = 32;
assign printdata[4] = 109;
assign printdata[5] = 97;
assign printdata[6] = 116;
assign printdata[7] = 114;
assign printdata[8] = 105;
assign printdata[9] = 120;
assign printdata[10] = 32;
assign printdata[11] = 105;
assign printdata[12] = 115;
assign printdata[13] = 58;
assign printdata[14] = 8'h0D;
assign printdata[15] = 8'h0A;
assign printdata[16] = 91;
assign printdata[17] = 32;
assign printdata[18] = data[0][0];
assign printdata[19] = data[0][1];
assign printdata[20] = data[0][2];
assign printdata[21] = data[0][3];
assign printdata[22] = 44;
assign printdata[23] = 32;
assign printdata[24] = data[3][0];
assign printdata[25] = data[3][1];
assign printdata[26] = data[3][2];
assign printdata[27] = data[3][3];
assign printdata[28] = 44;
assign printdata[29] = 32;
assign printdata[30] = data[6][0];
assign printdata[31] = data[6][1];
assign printdata[32] = data[6][2];
assign printdata[33] = data[6][3];
assign printdata[34] = 32;
assign printdata[35] = 93;
assign printdata[36] = 8'h0D;
assign printdata[37] = 8'h0A;
assign printdata[38] = 91;
assign printdata[39] = 32;
assign printdata[40] = data[1][0];
assign printdata[41] = data[1][1];
assign printdata[42] = data[1][2];
assign printdata[43] = data[1][3];
assign printdata[44] = 44;
assign printdata[45] = 32;
assign printdata[46] = data[4][0];
assign printdata[47] = data[4][1];
assign printdata[48] = data[4][2];
assign printdata[49] = data[4][3];
assign printdata[50] = 44;
assign printdata[51] = 32;
assign printdata[52] = data[7][0];
assign printdata[53] = data[7][1];
assign printdata[54] = data[7][2];
assign printdata[55] = data[7][3];
assign printdata[56] = 32;
assign printdata[57] = 93;
assign printdata[58] = 8'h0D;
assign printdata[59] = 8'h0A;
assign printdata[60] = 91;
assign printdata[61] = 32;
assign printdata[62] = data[2][0];
assign printdata[63] = data[2][1];
assign printdata[64] = data[2][2];
assign printdata[65] = data[2][3];
assign printdata[66] = 44;
assign printdata[67] = 32;
assign printdata[68] = data[5][0];
assign printdata[69] = data[5][1];
assign printdata[70] = data[5][2];
assign printdata[71] = data[5][3];
assign printdata[72] = 44;
assign printdata[73] = 32;
assign printdata[74] = data[8][0];
assign printdata[75] = data[8][1];
assign printdata[76] = data[8][2];
assign printdata[77] = data[8][3];
assign printdata[78] = 32;
assign printdata[79] = 93;
assign printdata[80] = 8'h0D;
assign printdata[81] = 8'h0A;
assign printdata[82] = 8'h0D;
assign printdata[83] = 8'h0A;
assign transmit =  print ;

always @(posedge clk) begin
	if(reset || !init_finish) begin
	test[0] = 68;
	test[1] = 76;
	test[2] = 65;
	test[3] = 66;
	test[4] = 95;
	test[5] = 84;
	test[6] = 65;
	test[7] = 71;
	byte0 = 0;
	load = 0;
   read = 0;
	check = 0;
   print = 0;
	sd_counter = 0;
	ck_counter = 0;
	out = 0;
	x = 0;
	y = 0;
	w = 1;
	rd_addr = 8192;
	rd_req = 1;
	end
	else begin
		if(!load && sd_valid) begin
			sd_counter = sd_counter + 1;
			if(sd_counter == 512) begin load = 1;	rd_req = 0; sd_counter = 0; check = 1; sd_counter = 0; w = 0; end
		end
		else if(check) begin
			byte0 = data_out;
			sd_counter = sd_counter + 1;
			if(byte0 == test[ck_counter]) ck_counter = ck_counter + 1;
			else begin check = 0; load = 0; 	rd_req = 1;ck_counter = 0; rd_addr = rd_addr + 1; w = 1;end
			if(ck_counter == 8) begin check = 0; read = 1;end
		end
		else if(read) begin
			byte0 = data_out;
			sd_counter = sd_counter + 1;
			if((byte0 >= 57 || byte0 <= 57) || (byte0 >= 65 && byte0 <= 70)) begin data[x][y] = byte0;y = y + 1; end
			if(y == 4) begin x = x + 1; y = 0; end
			if(x == 9) begin x = 0; y = 0; read = 0; print = 1; end
		end
		else if(print &&  !is_transmitting) begin
			out = printdata[p_counter];
			p_counter = p_counter + 1;
			if(p_counter == 84) print = 0;
		end
	end
end

endmodule
