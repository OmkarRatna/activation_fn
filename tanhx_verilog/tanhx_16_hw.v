
//rst is active high 
// 4 module instatiated comparator, priority encoder, rom memory and special cases
// en is active high 
module tanhx_16_hw #(parameter K=16,DWIDTH=32,EXPONENT_WIDTH=8, BIAS=8'd127)(input [DWIDTH-1:0] x_in,input clk,start,rst,output reg valid, output [DWIDTH-1:0] y_out);

wire [EXPONENT_WIDTH-1:0] exp_wo_bias,exp_wo_bias_1st;									
wire [K-1:0] c_out;
wire [DWIDTH-1:0] rm_data,rm_pos_1,rm_neg_1;
wire [9:0] cmp_ip,c1_in2,c2_in2,c3_in2,c4_in2,c5_in2,c6_in2,c7_in2,c8_in2,c9_in2,c10_in2,c11_in2,c12_in2,c13_in2,c14_in2,c15_in2,c16_in2;			//6bit for comparision of range of i/p
wire cmp_op;
reg x_gre_3,x_neg_pos,x_sp_case,x_sp_case_2nd;
reg x_neg_pos_1st,x_neg_pos_2nd;
reg x_gre_3_2nd;
reg start_ip;
wire x_gre_3_1st;
wire [$clog2(K)-1:0] pe_addr;
//wire [EXPONENT_WIDTH-1:0] test;
wire [EXPONENT_WIDTH+4:0] cmp_ip_1st;
wire [1:0] sp_addr;
wire sp_case;
wire [DWIDTH-1:0] sp_data;
reg [DWIDTH-1:0] x;
parameter IDLE_WAIT=2'b00,OPERN_WAIT=2'b01,START=2'b10;
reg  [1:0] present_state, next_state;

//assign test = x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1];
assign exp_wo_bias_1st= (x[DWIDTH-2:DWIDTH-EXPONENT_WIDTH-1] - BIAS);							// subtract bias from exponenet
assign exp_wo_bias= exp_wo_bias_1st[EXPONENT_WIDTH-1]?(~(exp_wo_bias_1st)+1'b1):(exp_wo_bias_1st);
assign cmp_ip_1st= exp_wo_bias_1st[EXPONENT_WIDTH-1]?({2'b00,{1'b1,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-12]}>>exp_wo_bias}):(({2'b01,x[DWIDTH-EXPONENT_WIDTH-2:DWIDTH-EXPONENT_WIDTH-12]})<<exp_wo_bias);		// input to comparator {2 bit of exp, 4 bit of mantissa =6 bits} 
assign cmp_ip= cmp_ip_1st[EXPONENT_WIDTH+4:3];

assign rm_pos_1=32'b00111111100000000000000000000000;
assign rm_neg_1=32'b10111111100000000000000000000000;

assign y_out=(valid)?(x_sp_case)?sp_data:(x_neg_pos)?(~x_gre_3)?{1'b1,rm_data[DWIDTH-2:0]}:rm_neg_1:(~x_gre_3)?rm_data:rm_pos_1:32'hxxxxxxxx;	// assign o/p data 1 if i/p is greater than 3 else apprx data

assign c1_in2 = 10'b0000101010;		//0.1640625
assign c2_in2 = 10'b0001010101;		//0.33203125		
assign c3_in2 = 10'b0001111111;		//0.49609375
assign c4_in2 = 10'b0010101010;		//0.6640625	
assign c5_in2 =	10'b0011010110;		//0.8359375
assign c6_in2 = 10'b0100000010;		//1.0078125
assign c7_in2 = 10'b0100101110;		//1.1796875
assign c8_in2 = 10'b0101011011;		//1.35546875
assign c9_in2 =	10'b0110001000;		//1.53125
assign c10_in2 = 10'b0110110101;	//1.70703125
assign c11_in2 = 10'b0111100011;	//1.88671875
assign c12_in2 = 10'b1000010010;	//2.0703125
assign c13_in2 = 10'b1001000011;	//2.26171875
assign c14_in2 = 10'b1001110111;	//2.46484375
assign c15_in2 = 10'b1010110010;	//2.6953125
assign c16_in2 = 10'b1100000000;	//3


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
			4'b0000: rm_data<=32'b00111101101010010010101100101110;		//0.082601893	// rom memory module 
			4'b0001: rm_data<=32'b00111110011110010110110001010000;		//0.243577242
			4'b0010: rm_data<=32'b00111110110010010001000001000010;		//0.392702167
			4'b0011: rm_data<=32'b00111111000001100011111100100101;		//0.524401003
			4'b0100: rm_data<=32'b00111111001000101100000110001101;		//0.635765873
			4'b0101: rm_data<=32'b00111111001110011111011110001011;		//0.726433442
			4'b0110: rm_data<=32'b00111111010011000100001111101111;		//0.797911587
			4'b0111: rm_data<=32'b00111111010110100100111110111011;		//0.852779073
			4'b1000: rm_data<=32'b00111111011001001101110011001101;		//0.893994181
			4'b1001: rm_data<=32'b00111111011011001010011010011111;		//0.924417447
			4'b1010: rm_data<=32'b00111111011100100101001010001000;		//0.946571813
			4'b1011: rm_data<=32'b00111111011101100110101000101111;		//0.96255771
			4'b1100: rm_data<=32'b00111111011110010101101111001110;		//0.974057088
			4'b1101: rm_data<=32'b00111111011110110111110101010101;		//0.982381139
			4'b1110: rm_data<=32'b00111111011111010001000000010001;		//0.9885264
			4'b1111: rm_data<=32'b00111111011111100100001101010011;		//0.993214757
			
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

