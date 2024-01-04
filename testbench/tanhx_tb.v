`timescale 1ns/1ps

`include "../tanhx_verilog/tanhx_4_hw.v"
//`include "../tanhx_verilog/tanhx_8_hw.v"
//`include "../tanhx_verilog/tanhx_12_hw.v"
//`include "../tanhx_verilog/tanhx_16_hw.v"
//`include "../mahati_code/tanh_new.v"
//`include "../tanhx_verilog/tanhx.v"

module tanhx_tb;

parameter DWIDTH=32, K=4, EXPONENT_WIDTH=8, BIAS=8'D127;
parameter file_size=54999;
parameter delay= 10*(file_size+5)*10;
reg [DWIDTH-1:0] x;
reg clk,start,rst;
wire [DWIDTH-1:0] y;
wire valid;
//wire [DWIDTH-1] cor_y;
reg [DWIDTH-1:0] temp [0:file_size-1];
//reg [DWIDTH-1:0] temp_cor[0:file_size-1];
reg [DWIDTH-1:0] memory [0:file_size-1];
tanhx_4_hw #(.K(4),.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(127)) dut (.x_in(x),.start(start),.clk(clk),.rst(rst),.y_out(y),.valid(valid));
//tanhx_8_hw #(.K(8),.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(127)) dut (.x_in(x),.start(start),.clk(clk),.rst(rst),.y_out(y),.valid(valid));
//tanhx_12_hw #(.K(12),.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(127)) dut (.x_in(x),.start(start),.clk(clk),.rst(rst),.y_out(y),.valid(valid));
//tanhx_16_hw #(.K(16),.DWIDTH(32),.EXPONENT_WIDTH(8),.BIAS(127)) dut (.x_in(x),.start(start),.clk(clk),.rst(rst),.y_out(y),.valid(valid));

//tanh_new dut_cor(.z(x),.clk(clk),.EN(en),.tanh_out(cor_y));
integer i,j,l,fd;
//integer fd_cor;
initial begin
	clk=1;
	rst=1; start=0;
	#7 rst=0;

end

always #5 clk=~clk;

initial begin
	
	$readmemb("../python_script/input_bin.txt",memory);
	for (i=0;i<file_size;i=i+1)
		begin
		@(posedge clk);
		start=1;
		x=memory[i];
		@(valid);
		start=0;
		@(posedge clk);
		end
end

initial begin
	fd= $fopen("../python_script/output_bin.txt","w");
	//fd_cor=$fopen("../python_script/cor_output_bin.txt","w");
	@(posedge clk);
	for (j=0;j<file_size;j=j+1)
	begin
	@(posedge valid);
	@(negedge clk);
		temp[j]=y;
	//	temp_cor[j]=cor_y;
	@(posedge clk);
	end
	
	for (l=0;l<file_size;l=l+1)
	begin
	@(posedge clk);
		$fwrite(fd,"%b\n",temp[l]);
	//	$fwrite(fd_cor,"%b\n",temp_cor[l]);
	end
	#10 $fclose(fd); 
	//$fclose(fd_cor);
end	
initial begin
	$monitor($time,"clk=%b x=%b y=%b ",clk,x,y);
	$dumpfile("tanhx_tb.vcd");
	$dumpvars(0,tanhx_tb);
	#delay $finish;
end

endmodule