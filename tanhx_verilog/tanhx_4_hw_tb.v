`timescale 1ns/1ns
//`include "tanhx_4_hw.v"
//`include "tanhx_8_hw.v"
//`include "tanhx_12_hw.v"
//`include "tanhx_16_hw.v"
`include "hdl_synthesis.v"

module tanhx_4_hw_tb;
parameter DWIDTH=32;
reg [DWIDTH-1:0] x;
reg clk,rst,start;
wire [DWIDTH-1:0] y;
wire valid;
tanhx_4_hw  dut (.x_in(x),.clk(clk),.start(start),.rst(rst),.y_out(y),.valid(valid));

always #5 clk= ~clk;
initial begin
clk=0; start=0;
#2 rst=1; 
#5 rst=0; 
#1   start=1;
	x=32'b00111111100111010111000010100100;		//1.23
@(valid);
@(posedge clk);
start=0;
#9 start=1; x=32'b00111111000110011001100110011010;		//0.6
@(valid);
@(posedge clk);
start=0;
#10 start=1; x=32'b01000000000001111010111000010100; 	//2.12
@(valid);
@(posedge clk);
start=0;
#10 start=1; x=32'b01000000101100001111010111000011; 	//5.53
@(valid);
@(posedge clk);
start=0;
#10 start=1; x=32'b00000000000000000000000000000000;		//0
#10 x=32'b01111111100000000000000000000000; 	//infinity
#10 x=32'b11111111100000000000000000000000; 	//neg infinity
#10 x=32'b00000000010010000000000000000000; 	//6.62*10^{-39}
#10 x=32'b01111111110010000000000000000000; 	//NAN
#10 x=32'b01000000000100110011001100110011;		//2.3
#10 x=32'b11000000000100110011001100110011;		//-2.3
#10 x=32'b01000001001011110001110111110000;	//10.944822525341984
#10 x=32'b01000001001010111111011100110000;	//10.747859689424384
#10 x=32'b11000001001010100100100011000000;	//-10.642767174556592
#10 x=32'b00111101111000110010010100010000; 	//0.11091
end

initial begin
//$dumpfile("tanhx_4_hw_tb.vcd");
$dumpfile("tanhx_hw_tb.vcd");
$dumpvars(0,tanhx_4_hw_tb);
$monitor($time,"x=%b,y=%b",x,y);
#300 $finish;
end

endmodule 
