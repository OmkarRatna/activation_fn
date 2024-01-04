
//rst is active high 
// 4 module instatiated comparator, priority encoder, rom memory and special cases
// en is active high 
module tanhx_8_hw #(parameter K=8,DWIDTH=32,EXPONENT_WIDTH=8, BIAS=8'd127)(input [DWIDTH-1:0] x_in,input clk,start,rst,output reg valid, output [DWIDTH-1:0] y_out);

wire [EXPONENT_WIDTH-1:0] exp_wo_bias,exp_wo_bias_1st;									
wire [K-1:0] c_out;
wire [DWIDTH-1:0] rm_data,rm_pos_1,rm_neg_1;
wire [7:0] cmp_ip,c1_in2,c2_in2,c3_in2,c4_in2,c5_in2,c6_in2,c7_in2,c8_in2;			//8 bit for comparision of range of i/p
wire cmp_op;
reg x_gre_3,x_neg_pos,x_sp_case,x_sp_case_2nd;
reg x_neg_pos_1st,x_neg_pos_2nd;
reg x_gre_3_2nd;
reg start_ip;
wire x_gre_3_1st;
wire [$clog2(K)-1:0] pe_addr;
//wire [EXPONENT_WIDTH-1:0] test,test_matissa;
wire [EXPONENT_WIDTH+2:0] cmp_ip_1st;
wire [1:0] sp_addr;
wire sp_case;
wire [DWIDTH-1:0] sp_data;
reg [DWIDTH-1:0] x;
parameter IDLE_WAIT=2'b00,OPERN_WAIT=2'b01,START=2'b10;
reg  [1:0] present_state, next_state;

//assign test = x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1];
//assign test_matissa=x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-9];
assign exp_wo_bias_1st= (x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1] - BIAS);							// subtract bias from exponenet
assign exp_wo_bias= exp_wo_bias_1st[EXPONENT_WIDTH-1]?(~(exp_wo_bias_1st)+1'b1):(exp_wo_bias_1st);
assign cmp_ip_1st= exp_wo_bias_1st[EXPONENT_WIDTH-1]?({2'b00,{1'b1,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-10]}>>exp_wo_bias}):(({2'b01,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-10]})<<exp_wo_bias);		// input to comparator {2 bit of exp, 4 bit of mantissa =6 bits} 
assign cmp_ip= cmp_ip_1st[EXPONENT_WIDTH+2:3];

assign rm_pos_1=32'b00111111100000000000000000000000;
assign rm_neg_1=32'b10111111100000000000000000000000;

assign y_out=(valid)?(x_sp_case)?sp_data:(x_neg_pos)?(~x_gre_3)?{1'b1,rm_data[DWIDTH-2:0]}:rm_neg_1:(~x_gre_3)?rm_data:rm_pos_1:32'hxxxxxxxx;	// assign o/p data 1 if i/p is greater than 3 else apprx data

assign c1_in2 = 8'b00001111;     	//0.234375
assign c2_in2 = 8'b00011110;		//0.46875
assign c3_in2 = 8'b00101110;		//0.71875
assign c4_in2 = 8'b00111111;		//0.984375
assign c5_in2=	8'b01010010;		//1.28125
assign c6_in2= 	8'b01100111;		//1.609375
assign c7_in2= 	8'b10000100;		//2.0625
assign c8_in2= 	8'b11000000;		//3

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
	begin start_ip<=1'bx;x<=32'hxxxxxxxx; end
	else
	begin
	start_ip<=start;
	if(start)
		x<=x_in;
	else
		x<=32'hxxxxxxxx;
	end
end

always@(posedge clk)
begin
if(rst)
	begin x_neg_pos_1st<=1'bx;   end
else
	begin x_neg_pos_1st<=(start_ip)?x[31]:1'bx;  end
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
	IDLE_WAIT:begin if(start_ip) begin valid=0; next_state=OPERN_WAIT; end
					else begin valid=0; next_state=IDLE_WAIT; end
			end
	OPERN_WAIT: begin if(!start_ip) begin valid=0; next_state=IDLE_WAIT; end
				else if(x_gre_3_2nd) begin valid=0; next_state=START; end
				else if(!x_neg_pos_2nd) begin valid=0; next_state=START; end
				else if(x_neg_pos_2nd) begin valid=0; next_state=START; end
				else if(x_sp_case_2nd) begin valid=0; next_state=START; end
				else begin valid=0; next_state=OPERN_WAIT; end
				end			
	START:begin if(!start_ip) begin valid=0; next_state=IDLE_WAIT; end
				else if(x_gre_3) begin valid=1; next_state=START; end
				else if(!x_neg_pos) begin valid=1; next_state=START; end
				else if(x_neg_pos) begin valid=1; next_state=START; end
				else if(x_sp_case) begin valid=1; next_state=START; end
				else begin valid=0; next_state=START; end
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
			3'b000: rm_data<=32'b00111101111011111101011001001110;		//0.117107972		// rom memory module 
			3'b001: rm_data<=32'b00111110101011101001011110010101;		//0.341000241
			3'b010: rm_data<=32'b00111111000010010111001000001111;		//0.536896618
			3'b011: rm_data<=32'b00111111001100011100101010001100;		//0.694496882
			3'b100:	rm_data<=32'b00111111010011111110001110111001;		//0.812068494
			3'b101:	rm_data<=32'b00111111011001001111111111001010;		//0.894528058
			3'b110: rm_data<=32'b00111111011100110010110111110111;		//0.949920134
			3'b111: rm_data<=32'b00111111011111000101100010101001;		//0.985727829
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
else if(exp_wo_bias==1 && sp_case_in[DWIDTH-EXPONENT_WIDTH-2:0]>=4194304 || exp_wo_bias>=2)	//FOR NUMBER > 3 
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
			2'b00: sp_data<=32'b00000000000000000000000000000000;				// 0 
			2'b01: sp_data<=32'b00111111100000000000000000000000;				// 1 
			2'b10: sp_data<=32'b10111111100000000000000000000000;				//-1
			2'b11: sp_data<=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;				//garbage data
		endcase
	end
endmodule

