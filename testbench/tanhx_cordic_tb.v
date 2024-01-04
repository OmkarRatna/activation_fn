`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2023 16:04:23
// Design Name: 
// Module Name: tanh_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "../mahati_code/tanhx/tanh_new.v"
module tanh_tb;

	// Inputs
	reg clk;
	reg EN;
	

	// Outputs
//	wire signed [15:0] result;
	
//	reg [8:-23] z;
//	reg  [31:0] z;
//	wire [31:0] sigmoid;


reg [8:-23] z;
wire [31:0] tanh_out;
	
//	reg [8:-23] e1, e2, e3, e4, e5, e6, e7, e8, e9, e10;
//	wire [8:-23] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10;


//reg [8:-23] z;
//wire [31:0] softmax_out;
	parameter DWIDTH=32, file_size=54999;
    integer i;
    integer fd;
    reg [DWIDTH-1:0] memory [0:file_size-1];  
        
//        	 Instantiate the Unit Under Test (UUT)
//	sigmoid_new uut (
//		.clk(clk), 
//		.EN(EN), 
//		.x(z),
//		.sigmoid(sigmoid)
//    );
    

     tanh_new inst1(clk,EN,z,tanh_out);
        
//        initial
//        begin
        
//        clk = 1;
//        EN = 1;
//        z=32'h3f800000;
//        #20;
//        EN = 0;
//        #6000;
//        $finish;

//        end
        
        
        
//        initial
//        begin
//        clk = 1;
//        end

    initial 
        begin
			clk =1;
            fd = $fopen("../python_script/output_bin.txt","w");
			$readmemb("../python_script/input_bin.txt",memory);
            for(i=0;i<5 ;i=i+1)
            begin
                EN = 1;
				z=memory[i];
                //z = $urandom_range(953267941, 1065353217);
				//clk = ~clk;
		@(posedge clk);
                #20;
                EN = 0;
                #1000;
                $fwrite(fd,"%32b\n",tanh_out);
            end      
	    #5
	    $fclose(fd);
	    $finish;
        end
		
	initial begin
			$monitor($time,"z=%h,clk=%b,EN=%b,tanh_out=%h",z,clk,EN,tanh_out);
	
	end
//        initial 
//        begin
////    clk =1;
//            fd = $fopen("/home/iiit-1/mahati/out_files/cordic_posit/fp32/sigmoid_new/posit_hypb_inout_new.txt","w");
    
//            for(i=0;i<550000 ;i=i+1)
//            begin
            
//                EN = 1;
//                z = $urandom_range(953267941, 1065353217);
////            clk = ~clk;
//                #20;
//                EN = 0;
//                #1000;
//                $fwrite(fd,"%d,%32b,%32b,\n",i,z,sigmoid);
               
                
//            end
    
//     $finish;
    
//    $fclose(fd);
//        end




        
//        always
//        begin
//        #5;
//        clk = ~clk; 
//        end
    
    


///////////////////////////////////////// For softmax parallel   
/*
    softmax_parallel_new sf1(e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,clk,EN,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);

    initial begin

        clk = 1;
//        e1= 16'h3dcc;
        
//        #10;

        e1= 32'h3dcccccd;

        e2= 32'h3e4ccccd;

        e3= 32'h3e99999a;

        e4= 32'h3ecccccd;

        e5= 32'h3f000000;

        e6= 32'h3f19999a;

        e7= 32'h3f333333;

        e8= 32'h3f4ccccd;

        e9= 32'h3f666666;

        e10= 32'h3f800000;
        
        EN = 1; #20;
        EN = 0;
        #6000;
 
    $finish;
     end
     */

/////////////////////////////////////////////////////



///////////////////////////////////////// For softmax parallel  ---- multiple combo

   /* softmax_parallel_new sf1(e1,e2,e3,e4,e5,e6,e7,e8,e9,e10,clk,EN,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);

            
        initial
        begin
        
        clk = 1;

        end


    initial 
    begin


        fd = $fopen("/home/iiit-1/mahati/out_files/cordic_posit/fp32/softmax/posit_hypb_inout_new.txt","w");
    
        for(i=0;i<150000;i=i+1)
        begin

            e1 = $urandom_range(953267941, 1065353217);
    
            e2=  $urandom_range(953267941, 1065353217);
    
            e3=  $urandom_range(953267941, 1065353217);
    
            e4=  $urandom_range(1000000000, 1065353217);
    
            e5=  $urandom_range(953267941, 1065353217);
    
            e6=  $urandom_range(1000000000, 1065353217);
    
            e7=  $urandom_range(953267941, 1065353217);
    
            e8=  $urandom_range(1000000000, 1065353217);
    
            e9=  $urandom_range(953267941, 1065353217);
    
            e10=  $urandom_range(841731191, 1065353217);
        
            EN = 1; #20;
            EN = 0;
            #1000;
            
            $fwrite(fd,"%d,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,%32b,\n",i,
                                           e1, e2, e3, e4, e5, e6, e7, e8, e9, e10,
                                           s1, s2, s3, s4, s5, s6, s7, s8, s9, s10);
                    
        end
 
        $finish;
        
        $fclose(fd);
        
    
     end
    

/////////////////////////////////////////////////////













///////////////////////////////////////// For softmax pipeline

// softmax_pipeline sf2 (.clk(clk),.EN(EN),.z(z),.softmax_out(softmax_out));
 
 
//  initial begin

//        clk = 1;
//        z= 16'h3dcc;
//        EN = 1; #10;
////        #10;
//EN = 0;
////        z= 16'h3dcc;
////        #505;
//#5;
//        z= 16'h3e4c;
////EN = 1; #15;
////        EN = 0;
//        #10;
////        #505;
//        z= 16'h3e99;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3ecc;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f00;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f19;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f33;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f4c;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f66;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
//        z= 16'h3f80;
//        #10;
////        EN = 1; #15;
////        EN = 0;
////        #505;
        
//    //     for(i=0;i<88;i=i+1)
//    //    begin
//    //     @(posedge CLK);
//    //     while(clk_num<20)
//    //     begin
//    //         @(posedge CLK)
//    //         clk_num= clk_num+1;
//    //         if(clk_num==19)
//    //         begin
//    //             $fwrite(file,"%b\n",result);
//    //             EN =1;
//    //         end
//    //     end
//    //     #5;
//    //     EN = 0;
//    //     z = z+8'd1;
//    //     clk_num=0;
//    //    end
//    //    $fclose(file);
//    //    $stop;  
    
//    #1000;
//    $finish;
//     end

///////////////////////////////////////// 



///////////////////////////////////////// For softmax serial
    softmax_serial sf3 (.clk(clk),.EN(EN),.z(z),.softmax_out(softmax_out));
    
    initial begin

        clk = 1;
        z= 16'h3dcc;
        EN = 1; #15;
//        #10;
EN = 0;
//        z= 16'h3dcc;
        #505;
        z= 16'h3e4c;
EN = 1; #15;
        EN = 0;
        
        #505;
        z= 16'h3e99;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3ecc;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f00;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f19;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f33;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f4c;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f66;
        EN = 1; #15;
        EN = 0;
        #505;
        z= 16'h3f80;
        EN = 1; #15;
        EN = 0;
        #505;
        
    //     for(i=0;i<88;i=i+1)
    //    begin
    //     @(posedge CLK);
    //     while(clk_num<20)
    //     begin
    //         @(posedge CLK)
    //         clk_num= clk_num+1;
    //         if(clk_num==19)
    //         begin
    //             $fwrite(file,"%b\n",result);
    //             EN =1;
    //         end
    //     end
    //     #5;
    //     EN = 0;
    //     z = z+8'd1;
    //     clk_num=0;
    //    end
    //    $fclose(file);
    //    $stop;  
    
//    #1000;
    $finish;
     end
*/
 /////////////////////////////////////////////////////////////////

    always #5 clk=~clk;

endmodule
