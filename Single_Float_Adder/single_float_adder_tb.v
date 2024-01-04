`timescale 1ns/1ps
`include "single_float_adder.v"
module single_float_adder_tb;

reg clk,rst;
reg [31:0]X,Y;
reg ip_ready;
wire [31:0]sum;
wire valid;

always #5 clk = ~clk;

single_float_adder #(.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(127)) dut (.clk(clk),.rst(rst),.a(X),.b(Y),.ip_ready(ip_ready),.sum(sum),.valid(valid));


initial
begin
clk=0; 
rst=1;
#7 rst=0; ip_ready=1'b1;
X=32'b00111111010011001100110011001101;
Y=32'b10111111000000000000000000000000;
@(valid)
ip_ready=1'b0;
#7 X=32'b00111111100111110111110011101110; //1.246
Y=32'b01000001001001110011001100110011; //10.45
#7  ip_ready=1'b1;


end      
initial 
begin
$dumpfile("single_float_add.vcd");
$dumpvars(0,single_float_adder_tb);
$monitor($time,"X=%d, Y=%d, sum=%d ",X,Y,sum);
#200 $finish;
end

endmodule