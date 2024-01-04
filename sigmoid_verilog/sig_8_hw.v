
//rst is active high 
// 3 module instatiated comparator, priority encoder and rom memory
// en is active high 
module sig_8_hw #(parameter K=8,DWIDTH=32,EXPONENT_WIDTH=8, BIAS=8'd127)(input [DWIDTH-1:0] x_in,input clk,start,rst,output reg valid, output [DWIDTH-1:0] y_out);

wire [EXPONENT_WIDTH-1:0] exp_wo_bias,exp_wo_bias_1st;									
wire [K-1:0] c_out;
wire [DWIDTH-1:0] rm_data,rm_pos_1,rm_neg_1;
wire [7:0] cmp_ip,c1_in2,c2_in2,c3_in2,c4_in2,c5_in2,c6_in2,c7_in2,c8_in2;			//6bit for comparision of range of i/p
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
wire [EXPONENT_WIDTH+2:0] cmp_ip_1st;
wire [DWIDTH-1:0] rm_neg_05,rm_pos_05;
reg start_ip;
reg [DWIDTH-1:0] x;
parameter IDLE_WAIT=2'b00,START=2'b01,ADD_WAIT=2'b10;
reg [1:0] present_state, next_state;

assign exp_wo_bias_1st= (x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1] - BIAS);							// subtract bias from exponenet
assign exp_wo_bias= exp_wo_bias_1st[EXPONENT_WIDTH-1]?(~(exp_wo_bias_1st)+1'b1):(exp_wo_bias_1st);					
assign cmp_ip_1st= exp_wo_bias_1st[EXPONENT_WIDTH-1]?({3'b000,{1'b1,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-9]}>>exp_wo_bias}):(({3'b001,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-9]})<<exp_wo_bias);																																																												  
assign cmp_ip = cmp_ip_1st[EXPONENT_WIDTH+2:3];

assign rm_pos_1=32'b00111111100000000000000000000000;
assign rm_neg_1=32'b00000000000000000000000000000000;

assign rm_neg_05=32'b10111111000000000000000000000000; //-0.5
assign rm_pos_05=32'b00111111000000000000000000000000; //0.5

assign y_out=(valid)?(x_sp_case)?sp_data:(x_neg_pos)?(~x_gre_3)?rm_neg_data:rm_neg_1:(~x_gre_3)?rm_data:rm_pos_1:32'hxxxxxxxx;	// assign o/p data 1 if i/p is greater than 3 else apprx data

assign c1_in2 = 8'b00001110;	//0.4375
assign c2_in2 = 8'b00011100;	//0.875
assign c3_in2 = 8'b00101011;	//1.34375
assign c4_in2 = 8'b00111010;	//1.8125
assign c5_in2 = 8'b01001011;	//2.34375
assign c6_in2 = 8'b01011110;	//2.9375
assign c7_in2 = 8'b01110110;	//3.6875
assign c8_in2 = 8'b10100000;	//5

single_float_adder #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.BIAS(BIAS)) subtractor_neg_1st(.a(rm_data[DWIDTH-1:0]),.b(rm_neg_05),.clk(clk),.rst(rst),.ip_ready(ip_adder_ready&!valid),.sum(rm_neg_calculate_data),.valid(valid_sub_1st));
single_float_adder #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.BIAS(BIAS)) subtractor_neg_2nd(.a(rm_pos_05),.b({1'b1,rm_neg_calculate_data[DWIDTH-2:0]}),.clk(clk),.rst(rst),.ip_ready(valid_sub_1st),.sum(rm_neg_data),.valid(valid_sub_2nd));

special_cases #(.DWIDTH(DWIDTH),.EXPONENT_WIDTH(EXPONENT_WIDTH),.K_CLUSTER(K)) sp (.sp_case_in(x),.exp_wo_bias_1st(exp_wo_bias_1st),.exp_wo_bias(exp_wo_bias),.sp_case_clk(clk),.sp_case(sp_case),.sp_case_addr(sp_addr),.x_gre_3(x_gre_3_1st));


comparator #(.CWIDTH(8)) c1 (.c_in1(cmp_ip),.c_in2(c1_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[0]));
comparator #(.CWIDTH(8)) c2 (.c_in1(cmp_ip),.c_in2(c2_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[1]));		// comparator module to determine range of i/p
comparator #(.CWIDTH(8)) c3 (.c_in1(cmp_ip),.c_in2(c3_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[2]));
comparator #(.CWIDTH(8)) c4 (.c_in1(cmp_ip),.c_in2(c4_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[3]));
comparator #(.CWIDTH(8)) c5 (.c_in1(cmp_ip),.c_in2(c5_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[4]));
comparator #(.CWIDTH(8)) c6 (.c_in1(cmp_ip),.c_in2(c6_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[5]));
comparator #(.CWIDTH(8)) c7 (.c_in1(cmp_ip),.c_in2(c7_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[6]));
comparator #(.CWIDTH(8)) c8 (.c_in1(cmp_ip),.c_in2(c8_in2),.c_clk(clk),.c_rst(rst),.c_out(c_out[7]));


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
	8'bxxxxxxx1: pe_out=3'b000;
	8'bxxxxxx10: pe_out=3'b001;					// priority encoder generates address for rom 
	8'bxxxxx100: pe_out=3'b010;
	8'bxxxx1000: pe_out=3'b011;
	8'bxxx10000: pe_out=3'b100;	
	8'bxx100000: pe_out=3'b101;
	8'bx1000000: pe_out=3'b110;
	8'b10000000: pe_out=3'b111;
	default: pe_out=3'bxxx;
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
			3'b000: rm_data<=32'b00111111000011011111010011000111;	//0.554516236		// rom memory module 
			3'b001: rm_data<=32'b00111111001010001100011101000000;	//0.65929029
			3'b010: rm_data<=32'b00111111010000001001111100110111;	//0.752429407
			3'b011: rm_data<=32'b00111111010101000101001101001010;	//0.829395894
			3'b100:	rm_data<=32'b00111111011000111001100011110000;	//0.889052382
			3'b101: rm_data<=32'b00111111011011101101101110011100;	//0.933038458
			3'b110: rm_data<=32'b00111111011101101110011010011101;	//0.964456358
			3'b111: rm_data<=32'b00111111011111001000010010100101;	//0.986399
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