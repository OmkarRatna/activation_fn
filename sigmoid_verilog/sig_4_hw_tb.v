`timescale 1ns/1ns
//`include "sig_4_hw.v"
//`include "sig_8_hw.v"
`include "sig_12_hw.v"
//`include "sig_16_hw.v"

module sig_4_hw_tb;
parameter DWIDTH=32;
reg [DWIDTH-1:0] x;
reg clk,rst,start;
wire [DWIDTH-1:0] y;
wire valid;
sig_12_hw #(.K(12),.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(8'd127)) dut (.start(start),.x_in(x),.clk(clk),.rst(rst),.y_out(y),.valid(valid));

always #5 clk= ~clk;
initial begin
clk=0; 
#2 rst=1; start=0;
#5 rst=0; start=1;
    x=32'b00111111100111010111000010100100;		//1.23
#10 start=0;
#9 start=1; x=32'b00111111000110011001100110011010;		//0.6
#10 x=32'b01000000000001111010111000010100; 	//2.12
#10 x=32'b01000000101100001111010111000011; 	//5.53
#10 x=32'b00000000000000000000000000000000;		//0
#10 x=32'b01111111100000000000000000000000; 	//infinity
#10 x=32'b11111111100000000000000000000000; 	//neg infinity
#10 x=32'b00000000010010000000000000000000; 	//6.62*10^{-39}
#10 x=32'b01111111110010000000000000000000; 	//NAN
#10 x=32'b11000000000100110011001100110011;		//-2.3
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(valid);
start=0;
#10 start=1; x=32'b10111111101011000010100011110110;	//-1.345
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(valid);
start=0;
#12 start=1; x=32'b01000001001011110001110111110000;	//10.944822525341984
#10 x=32'b01000001001010111111011100110000;	//10.747859689424384
#10 x=32'b11000001001010100100100011000000;	//-10.642767174556592
#10 x=32'b00111101111000110010010100010000; 	//0.11091
end

initial begin
//$dumpfile("sig_4_hw_tb.vcd");
$dumpfile("sig_hw_tb.vcd");
$dumpvars(0,sig_4_hw_tb);
$monitor($time,"x=%b,y=%b",x,y);
#900 $finish;
end

endmodule 