`timescale 1ns/1ps
`include "Float_Add.v"
module Float_Add_tb;

reg clk,rst,start;
reg [31:0]X,Y;
wire [31:0]sum;
wire valid;

always #5 clk = ~clk;

Float_Add inst (clk,rst,start,X,Y,valid,sum);


initial
begin
//X=32'h40d80000; Y=32'hc0700000;	//6.75,-3.75
//X=32'hc0d80000; Y=32'h40700000;	//-6.75,3.75
X=32'h40700000; Y=32'hc0d80000;	        //3.75,-6.75
//X=32'hc0700000; Y=32'h40d80000;	//-3.75,6.75
clk=1'b1; rst=1'b0; start=1'b0;
#10 rst = 1'b1;
#10 start = 1'b1;
#10 start = 1'b0;
@valid
#10 X=32'b00111111100111110111110011101110; //1.246
Y=32'b01000001001001110011001100110011; //10.45
//#10 X=32'hc0d80000; Y=32'hc0700000;    //-6.75,-3.75
start = 1'b1;
#10 start = 1'b0;

end      
initial 
begin
$dumpfile("float_add.vcd");
$dumpvars(0,Float_Add_tb);
$monitor($time,"X=%d, Y=%d, sum=%d ",X,Y,sum);
#200 $finish;
end

endmodule