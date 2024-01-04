#python program to convert a real value
#to IEEE 754 floating point representation


def floatingPoint(real_no):
    sign_bit = 0    #default sign bit = 0
        
    if(real_no<0):
        sign_bit=1

    #converting real no to absolute value
    
    real_no=abs(real_no)
    
    #converting integer part to binary
    int_bin= bin(int(real_no))[2:]
    
    #converting fraction part to binary
    frac_part= real_no - int(real_no)

    #if no is in between -1 to 1 23 bits are used for converting fraction part for rest
    # of the input 16 bits are used
    if (real_no<1 and real_no>-1):
        frac_bin=frac_2_bin(frac_part,23)
    else:
        frac_bin= frac_2_bin(frac_part,16)
    
    #getting index where bit was high for the first 
    #time in binary representation of integer part 
    #the number
    # for no in between -1 to 1 index is determined by fraction part else integer part is used
    if(real_no<1 and real_no>-1):
        indx= frac_bin.index('1')+1
        frac_part_on=1
    else:
        indx= int_bin.index('1')
        frac_part_on=0
    
    #the exponent is the no by which we have right shifted
    #the decimal and added bias of 127
    # seperated for fraction and integer part
    if(real_no<1 and real_no>-1):
        exponent_bin= bin(127-indx)[2:]
    else:
        exponent_bin= bin((len(int_bin)-indx-1)+127)[2:]
    exponent_bin= ('0'*(8-len(exponent_bin))) + exponent_bin

    # mantissa is calculated based on number range
    if(real_no<1 and real_no>-1):
        mantissa_bin=frac_bin[indx:]
    else:
        mantissa_bin= int_bin[indx + 1: ] + frac_bin
    #adding integer and fractional part in  binary format
    #to complete mantissa part

    
    #making mantissa of length 23 bit by adding zeros to lsb
    mantissa_bin = mantissa_bin + ('0'*(23-len(mantissa_bin)))
   
    ieee_fp_32= str(sign_bit) + exponent_bin + mantissa_bin
    
    
    return ieee_fp_32
  
  
def frac_2_bin(frac_part,n):
    frac_bin= str()         #creating empty string to store bits
    
    frac_mul=frac_part
    
    #10 bits are used to convert fraction part into binary
    for i in range (n):
        temp= frac_mul*2
        frac_bin += str(int(temp))
        frac_mul=temp - int(temp)
 
 
    return frac_bin

if __name__ == "__main__":


        line=[];
        single_bit_expr=[];
file1=open("input_decoded.txt",'r')
file2 = open("input_bin.txt",'w')

#reading random data from file strip() is used for removing \n from list
for i in file1:
        line.append(i.strip())

#passing data to convert into ieee format
for x in line:
        #print( x + "\n")
        ieee_32=floatingPoint(float(x));
        single_bit_expr.append(str(ieee_32))
        
#writing output data into new file 
for j in single_bit_expr:
        file2.write(j+'\n');
file2.close()
file1.close()

    

