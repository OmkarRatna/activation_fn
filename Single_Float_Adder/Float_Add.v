module Float_Add(clk,rst,start,X,Y,valid,sum);

input clk;
input rst;
input start;
input [31:0]X,Y;	//In IEEE754 format
output [31:0]sum;	//In IEEE754 format
output valid;

reg X_sign;
reg Y_sign;
reg sum_sign,next_sum_sign;
reg [7:0] X_exp;
reg [7:0] Y_exp;
reg [7:0] sum_exp,next_sum_exp;
reg [23:0] X_mant, Y_mant;
reg [23:0] X_mantissa, Y_mantissa; //24 bits = 23 + implicit 1
reg [24:0] sum_mantissa, next_sum_mantissa; //sum is 25 bits

reg [8:0] expsub,abs_diff;
reg [24:0] sum_mantissa_temp;
reg [1:0] next_state, pres_state;
reg valid, next_valid;

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter SHIFT_MANT = 2'b10;

assign sum = {sum_sign,sum_exp,sum_mantissa[22:0]};
assign add_carry = sum_mantissa[24] & !(X_sign ^ Y_sign);	//carry during add
assign sub_borrow = sum_mantissa_temp[24] & (X_sign ^ Y_sign); //borrow during sub

always @ (posedge clk or negedge rst)
begin
if(!rst)
begin
	valid 	     <= 1'b0;
	pres_state   <= 2'd0;
	sum_exp      <= 8'd0;
	sum_mantissa <= 25'd0;
	sum_sign     <= 1'b0;
end
else
begin
	valid 	     <= next_valid;
	pres_state   <= next_state;
	sum_exp      <= next_sum_exp;
	sum_mantissa <= next_sum_mantissa;
	sum_sign     <= next_sum_sign;
end
end

always @ (*)
begin 
next_valid = 1'b0;
X_sign = X[31];
X_exp = X[30:23];
X_mant = {1'b1,X[22:0]};	
Y_sign = Y[31];
Y_exp = Y[30:23];
Y_mant = {1'b1,Y[22:0]};
next_sum_sign = sum_sign;		
next_sum_exp = 8'd0;
next_sum_mantissa = 25'd0;
next_state = IDLE;
sum_mantissa_temp = 25'd0;

case(pres_state)
IDLE:
begin
	next_valid = 1'b0;
	X_sign = X[31];
	X_exp = X[30:23];
	X_mant = {1'b1,X[22:0]};	//Implicit 1 added
	Y_sign = Y[31];
	Y_exp = Y[30:23];
	Y_mant = {1'b1,Y[22:0]};
	next_sum_sign = 1'b0;
	next_sum_exp = 8'd0;
	next_sum_mantissa = 25'd0;
	next_state = (start) ? START : pres_state;
end

START:
begin
    expsub = X_exp - Y_exp;
    abs_diff = expsub[8] ? !(expsub[7:0])+1'b1 : expsub[7:0];	//Absolute difference
    X_mantissa = expsub[8] ? X_mant >> abs_diff : X_mant;	//X mant shifts if expsub[8]
    Y_mantissa = expsub[8] ? Y_mant : Y_mant >> abs_diff;   //Y mant shifts if !expsub[8]
    next_sum_exp = expsub[8] ? Y_exp : X_exp;			//Greater exp taken
    sum_mantissa_temp = !(X_sign ^ Y_sign) ? X_mantissa + Y_mantissa :	//Add mantissas
			 (X_sign) ? Y_mantissa - X_mantissa :
			 (Y_sign) ? X_mantissa - Y_mantissa : sum_mantissa;
    next_sum_mantissa = (sub_borrow) ? ~(sum_mantissa_temp)+1'b1 : sum_mantissa_temp; //2s comp if req
    next_sum_sign = ((X_sign & Y_sign) || sub_borrow);
    next_valid = 1'b0;	
    next_state = SHIFT_MANT;	
end

SHIFT_MANT:					//State to shift Mantissa to make bit23 = 1
begin
    next_sum_exp = sum_mantissa[23] ? sum_exp : (add_carry)? sum_exp + 1'b1 : sum_exp - 1'b1;
    next_sum_mantissa = sum_mantissa[23] ? sum_mantissa : (add_carry) ? sum_mantissa >> 1 : sum_mantissa << 1;
    next_valid = sum_mantissa[23] ? 1'b1 : 1'b0;
    next_state = sum_mantissa[23] ? IDLE : pres_state;
end

endcase
end
endmodule