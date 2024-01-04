
//rst is active high 
// 3 module instatiated comparator, priority encoder and rom memory
// en is active high 
module sig_16_hw #(parameter K=16,DWIDTH=32,EXPONENT_WIDTH=8, BIAS=8'd127)(input [DWIDTH-1:0] x_in,input clk,start,rst,output reg valid, output [DWIDTH-1:0] y_out);

wire [EXPONENT_WIDTH-1:0] exp_wo_bias,exp_wo_bias_1st;									
wire [K-1:0] c_out;
wire [DWIDTH-1:0] rm_data,rm_pos_1,rm_neg_1;
wire [9:0] cmp_ip,c1_in2,c2_in2,c3_in2,c4_in2,c5_in2,c6_in2,c7_in2,c8_in2,c9_in2,c10_in2,c11_in2,c12_in2,c13_in2,c14_in2,c15_in2,c16_in2;			//6bit for comparision of range of i/p
wire cmp_op;
reg x_gre_3,x_neg_pos,x_sp_case,x_sp_case_2nd;
reg x_neg_pos_1st,x_neg_pos_2nd;
reg x_gre_3_2nd;
reg ip_adder_ready;
wire x_gre_3_1st;
wire [$clog2(K)-1:0] pe_addr;
wire [1:0] sp_addr;
wire sp_case;
wire [DWIDTH-1:0] sp_data,rm_neg_calculate_data,rm_neg_data;
wire [EXPONENT_WIDTH+4:0] cmp_ip_1st;
wire [DWIDTH-1:0] rm_neg_05,rm_pos_05;
reg start_ip;
reg [DWIDTH-1:0] x;
parameter IDLE_WAIT=2'b00,START=2'b01,ADD_WAIT=2'b10;
reg [1:0] present_state, next_state;

assign exp_wo_bias_1st= (x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1] - BIAS);							// subtract bias from exponenet
assign exp_wo_bias= exp_wo_bias_1st[EXPONENT_WIDTH-1]?(~(exp_wo_bias_1st)+1'b1):(exp_wo_bias_1st);		
					
assign cmp_ip_1st= exp_wo_bias_1st[EXPONENT_WIDTH-1]?({3'b000,{1'b1,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-11]}>>exp_wo_bias}):(({3'b001,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-11]})<<exp_wo_bias);																																																												  
assign cmp_ip = cmp_ip_1st[EXPONENT_WIDTH+4:3];

assign rm_pos_1=32'b00111111100000000000000000000000;
assign rm_neg_1=32'b00000000000000000000000000000000;

assign rm_neg_05=32'b10111111000000000000000000000000; //-0.5
assign rm_pos_05=32'b00111111000000000000000000000000; //0.5

assign y_out=(valid)?(x_sp_case)?sp_data:(x_neg_pos)?(~x_gre_3)?rm_neg_data:rm_neg_1:(~x_gre_3)?rm_data:rm_pos_1:32'hxxxxxxxx;	// assign o/p data 1 if i/p is greater than 3 else apprx data
assign c1_in2 = 10'b0000100101;		//0.2890625
assign c2_in2 = 10'b0001001010;		//0.578125
assign c3_in2 = 10'b0001110000;		//0.875
assign c4_in2 = 10'b0010010101;		//1.1640625
assign c5_in2 = 10'b0010111011;		//1.4609375
assign c6_in2 = 10'b0011100000;		//1.75
assign c7_in2 = 10'b0100000110;		//2.046875
assign c8_in2 = 10'b0100101011;		//2.3359375
assign c9_in2 = 10'b0101010001;		//2.6328125
assign c10_in2 = 10'b0101110111;	//2.9296875
assign c11_in2 = 10'b0110011110;	//3.234375
assign c12_in2 = 10'b0111000101;	//3.5390625
assign c13_in2 = 10'b0111101101;	//3.8515625
assign c14_in2 = 10'b1000010111;	//4.1796875	
assign c15_in2 = 10'b1001000110;	//4.546875
assign c16_in2 = 10'b1010000000;	//5


single_float_adder #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.BIAS(BIAS)) subtractor_neg_1st(.a(rm_data[DWIDTH-1:0]),.b(rm_neg_05),.clk(clk),.rst(rst),.ip_ready(ip_adder_ready&!valid),.sum(rm_neg_calculate_data),.valid(valid_sub_1st));
single_float_adder #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.BIAS(BIAS)) subtractor_neg_2nd(.a(rm_pos_05),.b({1'b1,rm_neg_calculate_data[DWIDTH-2:0]}),.clk(clk),.rst(rst),.ip_ready(valid_sub_1st),.sum(rm_neg_data),.valid(valid_sub_2nd));

special_cases #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.K_CLUSTER(K)) sp (.sp_case_in(x),.exp_wo_bias_1st(exp_wo_bias_1st),.exp_wo_bias(exp_wo_bias),.sp_case_clk(clk),.sp_case(sp_case),.sp_case_addr(sp_addr),.x_gre_3(x_gre_3_1st));


comparator #(.CWIDTH(10)) c1 (.c_in1(cmp_ip),.c_in2(c1_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[0]));
comparator #(.CWIDTH(10)) c2 (.c_in1(cmp_ip),.c_in2(c2_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[1]));		// comparator module to determine range of i/p
comparator #(.CWIDTH(10)) c3 (.c_in1(cmp_ip),.c_in2(c3_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[2]));
comparator #(.CWIDTH(10)) c4 (.c_in1(cmp_ip),.c_in2(c4_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[3]));
comparator #(.CWIDTH(10)) c5 (.c_in1(cmp_ip),.c_in2(c5_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[4]));
comparator #(.CWIDTH(10)) c6 (.c_in1(cmp_ip),.c_in2(c6_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[5]));
comparator #(.CWIDTH(10)) c7 (.c_in1(cmp_ip),.c_in2(c7_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[6]));
comparator #(.CWIDTH(10)) c8 (.c_in1(cmp_ip),.c_in2(c8_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[7]));
comparator #(.CWIDTH(10)) c9 (.c_in1(cmp_ip),.c_in2(c9_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[8]));
comparator #(.CWIDTH(10)) c10 (.c_in1(cmp_ip),.c_in2(c10_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[9]));
comparator #(.CWIDTH(10)) c11 (.c_in1(cmp_ip),.c_in2(c11_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[10]));
comparator #(.CWIDTH(10)) c12 (.c_in1(cmp_ip),.c_in2(c12_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[11]));
comparator #(.CWIDTH(10)) c13 (.c_in1(cmp_ip),.c_in2(c13_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[12]));
comparator #(.CWIDTH(10)) c14 (.c_in1(cmp_ip),.c_in2(c14_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[13]));
comparator #(.CWIDTH(10)) c15 (.c_in1(cmp_ip),.c_in2(c15_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[14]));
comparator #(.CWIDTH(10)) c16 (.c_in1(cmp_ip),.c_in2(c16_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[15]));

priority_encoder #(.K_CLUSTER(K)) pe (.pe_in(c_out),.pe_out(pe_addr));		//priority encoder to generates address of rom memory	

mem_rom_data #(.K_CLUSTER(K),.DWIDTH(DWIDTH)) rm (.rm_addr(pe_addr),.rm_clk(clk),.rm_rst(rst),.rm_data(rm_data));		//rom module to determine approximate function
mem_rom_sp_case #(.K_CLUSTER(K),.DWIDTH(DWIDTH)) mrsp (.sp_addr(sp_addr),.sp_clk(clk),.sp_case(sp_case),.sp_data(sp_data));

always@(posedge clk)
begin
if(rst)
	begin start_ip=1'bx;  end
else
	begin  start_ip=start;
	if(start)
		x<=x_in;
	else
		x<=32'hxxxxxxxx;
	end
end

always @(posedge clk)
begin
if(rst)
	begin x_neg_pos_1st<=1'bx; end
else
	begin  x_neg_pos_1st<=x[31]; end
end
always @(posedge clk)
begin
if(rst)
	begin  x_neg_pos_2nd<=1'bx;  x_sp_case_2nd<=1'bx; x_gre_3_2nd<=1'bx; end
else
	begin  x_neg_pos_2nd<=x_neg_pos_1st;  x_sp_case_2nd<=sp_case; x_gre_3_2nd<=x_gre_3_1st;  end
end
always @(posedge clk)
begin
if(rst)
	begin x_neg_pos<=1'bx;  x_sp_case<=1'bx; x_gre_3<=1'bx; end
else
	begin x_neg_pos<=x_neg_pos_2nd; x_sp_case<=x_sp_case_2nd; x_gre_3<=x_gre_3_2nd;end
end

always@(*)
begin
if(rst)
	ip_adder_ready=1'b0;
else
	ip_adder_ready=(x_sp_case_2nd)?0:(x_neg_pos_2nd)?(~x_gre_3_2nd)?1:0:0 ;
end
always @(posedge clk)
begin
if(rst)
	present_state<=0;
else
	present_state<=next_state;
end
always @(*)
begin
	case(present_state)
	IDLE_WAIT:begin if(start_ip) begin valid=0; next_state=START; end
					else begin valid=0; next_state=IDLE_WAIT; end
			end
	START:begin if(!start_ip) begin valid=0; next_state=IDLE_WAIT; end
				else if(x_gre_3) begin valid=1; next_state=START; end
				else if(!x_neg_pos) begin valid=1; next_state=START; end
				else if(x_neg_pos) begin valid=0; next_state=ADD_WAIT; end
				else if(x_sp_case) begin valid=1; next_state=START; end
				else begin valid=0; next_state=START; end
		end
	ADD_WAIT:begin if(!start_ip) begin valid=0; next_state=IDLE_WAIT; end
			else if(valid_sub_2nd)begin valid=1; next_state=IDLE_WAIT; end
			else begin valid=0; next_state=ADD_WAIT; end
		end
	endcase
	
end
endmodule


module comparator #(parameter CWIDTH=6)(input [CWIDTH-1:0] c_in1,c_in2, input c_clk,c_rst, output reg c_out);
always @ (posedge c_clk)
begin
if(c_rst)
	c_out <= 0;
else if(c_in1<c_in2)						// comparator compares two input for less than 
	c_out <= 1;
else
	c_out <= 0;

end
endmodule

module priority_encoder #(parameter K_CLUSTER=4)(input [K_CLUSTER-1:0] pe_in, output reg [$clog2(K_CLUSTER)-1:0] pe_out);
always@(*)
begin
casex(pe_in)
	16'bxxxxxxxxxxxxxxx1: pe_out=4'b0000;
	16'bxxxxxxxxxxxxxx10: pe_out=4'b0001;					// priority encoder generates address for rom 
	16'bxxxxxxxxxxxxx100: pe_out=4'b0010;
	16'bxxxxxxxxxxxx1000: pe_out=4'b0011;
	16'bxxxxxxxxxxx10000: pe_out=4'b0100;	
	16'bxxxxxxxxxx100000: pe_out=4'b0101;
	16'bxxxxxxxxx1000000: pe_out=4'b0110;
	16'bxxxxxxxx10000000: pe_out=4'b0111;
	16'bxxxxxxx100000000: pe_out=4'b1000;
	16'bxxxxxx1000000000: pe_out=4'b1001;
	16'bxxxxx10000000000: pe_out=4'b1010;
	16'bxxxx100000000000: pe_out=4'b1011;
	16'bxxx1000000000000: pe_out=4'b1100;
	16'bxx10000000000000: pe_out=4'b1101;
	16'bx100000000000000: pe_out=4'b1110;
	16'b1000000000000000: pe_out=4'b1111;
	default: pe_out=4'bxxxx;
endcase
end
endmodule


module mem_rom_data #(parameter K_CLUSTER=4,DWIDTH=32)(input [$clog2(K_CLUSTER)-1:0] rm_addr, input rm_clk, rm_rst, output reg [DWIDTH-1:0] rm_data);
	always @(posedge rm_clk)
	begin
	if(rm_rst)
		rm_data <= 0;
	else
		case(rm_addr)
			4'b0000: rm_data<=32'b00111111000010010101010010101110;	//0.536448369		// rom memory module 
			4'b0001: rm_data<=32'b00111111000110111001100100011001;	//0.607804816
			4'b0010: rm_data<=32'b00111111001011001100000001001101;	//0.674809303
			4'b0011: rm_data<=32'b00111111001111000011111000101001;	//0.735323506
			4'b0100: rm_data<=32'b00111111010010011100000101100000;	//0.788106947
			4'b0101: rm_data<=32'b00111111010101010011000101000100;	//0.832782982
			4'b0110: rm_data<=32'b00111111010111101010000111110000;	//0.86965849
			4'b0111: rm_data<=32'b00111111011001100100001111001001;	//0.899471844
			4'b1000: rm_data<=32'b00111111011011000101010010111110; //0.923168062
			4'b1001: rm_data<=32'b00111111011100010001011000000000; //0.941741943
			4'b1010: rm_data<=32'b00111111011101001100010101111000; //0.956138147
			4'b1011: rm_data<=32'b00111111011101111001101100001010; //0.967209472
			4'b1100: rm_data<=32'b00111111011110011100011110101001; //0.975702812
			4'b1101: rm_data<=32'b00111111011110110111010100110001; //0.982256936
			4'b1110: rm_data<=32'b00111111011111001100011010001000; //0.987404336
			4'b1111: rm_data<=32'b00111111011111011101011101101100; //0.991568343
		endcase
	end
endmodule


module special_cases #(parameter DWIDTH=32,EXPONENT_WIDTH=8,K_CLUSTER=4)(input [DWIDTH-1:0] sp_case_in,input [EXPONENT_WIDTH-1:0] exp_wo_bias,exp_wo_bias_1st,input sp_case_clk, output reg [1:0] sp_case_addr, output reg sp_case,x_gre_3);
always@(posedge sp_case_clk)
begin
if(sp_case_in[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1]==0 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]==0)
	begin
	x_gre_3<=0;
	sp_case<=1; 							//ZERO VALUE
	sp_case_addr<=2'b00;
	end
else if(sp_case_in[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1]==255 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]==0 && sp_case_in[DWIDTH-1]==0)
	begin
	x_gre_3<=0;
	sp_case<=1;							//+INFINITY
	sp_case_addr<=2'b01;
	end
else if(sp_case_in[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1]==255 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]==0 && sp_case_in[DWIDTH-1]==1)
	begin
	x_gre_3<=0;
	sp_case<=1;							//-INFINITY
	sp_case_addr<=2'b10;
	end
else if(sp_case_in[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1]==0 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]!=0)	
	begin
	x_gre_3<=0;
	sp_case<=1;							//SUBNORMAL NUMBER
	sp_case_addr<=2'b00;
	end
else if(sp_case_in[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1]==255 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]!=0)
	begin
	x_gre_3<=0;
	sp_case<=1;							//NOT A NUMBER
	sp_case_addr<=2'b11;
	end	
else if(exp_wo_bias_1st[EXPONENT_WIDTH-1]==1)
	begin
	x_gre_3<=0;
	sp_case<=0;
	sp_case_addr<=2'bxx;
	end
else if(exp_wo_bias==2 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]>=2097152  || exp_wo_bias>=3)	//FOR NUMBER > 3 
	begin																	// EXPONENT_WIDTH>=1 AND MANTISSA>=4194304
	x_gre_3<=1;
	sp_case<=0;
	sp_case_addr<=2'bxx;
	end
else 
	begin
	x_gre_3<=0;
	sp_case<=0;
	sp_case_addr<=2'bxx;
	end
end
endmodule

module mem_rom_sp_case #(parameter K_CLUSTER=4,DWIDTH=32)(input [1:0] sp_addr, input sp_clk, sp_case, output reg [DWIDTH-1:0] sp_data);
	always @(posedge sp_clk)
	begin
	if(!sp_case)
		sp_data <= 0;						// special cases rom module
	else
		case(sp_addr)
			2'b00: sp_data<=32'b00111111000000000000000000000000;				// 0.5 
			2'b01: sp_data<=32'b00111111100000000000000000000000;				// 1 
			2'b10: sp_data<=32'b00000000000000000000000000000000;				//0
			2'b11: sp_data<=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;				//garbage data
		endcase
	end
endmodule

module single_float_adder #(parameter DWIDTH=32,EXPONENT_WIDTH=8,BIAS=8'd127)(input [DWIDTH-1:0]a,b,input ip_ready,rst,clk,output reg valid, output [DWIDTH-1:0]sum);

reg a_sign,b_sign;
reg [EXPONENT_WIDTH-1:0] a_exp,b_exp;
reg [DWIDTH-EXPONENT_WIDTH-1:0] a_mantissa,b_mantissa;	// Extract sign, exponent and mantissa information from input

reg [EXPONENT_WIDTH:0] sub_exp;
reg [EXPONENT_WIDTH-1:0] abs_diff;
reg [DWIDTH-EXPONENT_WIDTH:0] sum_mantissa_add_sub;					
reg [DWIDTH-EXPONENT_WIDTH-1:0] a_mantissa_shift,b_mantissa_shift;	// reg for operation 
reg final_sign,next_sign;															
reg [EXPONENT_WIDTH-1:0] final_exp,next_exp;
reg [DWIDTH-EXPONENT_WIDTH:0] final_mantissa,next_mantissa;
reg valid_sig;
reg [1:0] PS,NS;

parameter IDLE=2'b00;
parameter ADD=2'b01;
parameter NORMALIZE=2'b10;

wire sub_borrow,sum_carry;
/*wire [DWIDTH-1:0] sum_1st;
wire [DWIDTH:0] sp_fp_add_1st,sp_fp_add_2nd;
reg exp_equal;

assign sum_1st={final_sign,final_exp,final_mantissa[DWIDTH-EXPONENT_WIDTH-2:0]};
assign sp_fp_add_1st=a-b;
assign sp_fp_add_2nd=(sp_fp_add_1st[DWIDTH])?~(sp_fp_add_1st)+1'b1:sp_fp_add_1st;

assign sum=(exp_equal)?sp_fp_add_2nd[DWIDTH-1:0]:sum_1st;
*/
assign sum= {final_sign,final_exp,final_mantissa[22:0]};
assign sub_borrow = sum_mantissa_add_sub[24] & (a_sign ^ b_sign);	//borrow during sub
assign sum_carry = next_mantissa[24] & !(a_sign^b_sign);
/*
always @ (*)
begin
	if(a_exp==b_exp)
		exp_equal=1;
	else
		exp_equal=0;
end
*/
always@(posedge clk)
begin
	if(rst)
		begin
			final_exp<=0;
			final_sign<=0;
			final_mantissa<=0;
			valid<=0;
			PS<= 0;
		end
	else
		begin
			PS<=NS;
			final_exp<= next_exp;
			final_sign <= next_sign;
			final_mantissa<= next_mantissa;
			valid <= valid_sig;
		end
end

always @(*)
begin
sub_exp=0;
abs_diff=0;
a_mantissa_shift=0;
b_mantissa_shift=0;
next_exp=0;
sum_mantissa_add_sub=0;
next_mantissa=0;
next_sign=0;
NS=IDLE;

case(PS)
IDLE:begin
		a_sign=a[DWIDTH-1];
		b_sign=b[DWIDTH-1];
		a_exp=a[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1];			//assiging sign bit, exponent and mantissa values
		b_exp=b[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1];
		a_mantissa={1'b1,a[DWIDTH-EXPONENT_WIDTH-2:0]};
		b_mantissa={1'b1,b[DWIDTH-EXPONENT_WIDTH-2:0]};
		valid_sig=0;
		NS=(ip_ready)?ADD:IDLE;
	end
ADD:begin
		sub_exp =  a_exp-b_exp;				//calculate diff between two exponent
		abs_diff = sub_exp[EXPONENT_WIDTH]?~(sub_exp[EXPONENT_WIDTH-1:0])+1'b1:sub_exp[EXPONENT_WIDTH-1:0];	//take absoulte value of difference
		a_mantissa_shift = sub_exp[EXPONENT_WIDTH]?a_mantissa >> abs_diff: a_mantissa;		//shift mantissa by abs exponet diff of whose exponent is smaller 
		b_mantissa_shift = sub_exp[EXPONENT_WIDTH]?b_mantissa : b_mantissa >> abs_diff;
		next_exp = sub_exp[EXPONENT_WIDTH] ? b_exp:a_exp;			//final exponent is value whose exponent is greater
		sum_mantissa_add_sub=!(a_sign^b_sign)?a_mantissa_shift+b_mantissa_shift:(a_sign)?b_mantissa_shift-a_mantissa_shift:(b_sign)?a_mantissa_shift-b_mantissa_shift:0; //add or subtract mantissa values based on sign bit
		next_mantissa=(sub_borrow) ? ~(sum_mantissa_add_sub)+1'b1 : sum_mantissa_add_sub;	//take 2s complement if borrow occur during mantissa subtraction
		next_sign = ((a_sign & b_sign) || sub_borrow);	//final sign of output
		valid_sig=0;
		NS=NORMALIZE;
	end
NORMALIZE:begin
			next_exp= final_mantissa[23]? final_exp:(sum_carry)? final_exp+1'b1:final_exp-1'b1;
			next_mantissa=final_mantissa[23]?final_mantissa:(sum_carry)?final_mantissa>>1:final_mantissa<<1;
			valid_sig=final_mantissa[23]?1:0;
			NS = final_mantissa[23]?IDLE:NORMALIZE;
		end
endcase
end
endmodule