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