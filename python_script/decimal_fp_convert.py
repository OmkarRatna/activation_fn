#script to convert single precision binary number into decimal real value
def decimalPointconvert(bin):
    #sign bit is decided to determine positve and negative number
    n=0;
    if (bin[0]==1):
        n=1;
    #exponent value is calculated
    E=bin_2_dec(bin[1:9])

    #manitssa value is calculated
    M=bin_2_frac(bin[9:32])
    
    #final value is calculated based on IEEE FP equation
    #special cases are checked for IEEE conversion
    sp_value, sp_case = specialcases(n,E,M)

    if(sp_case==0):
        decimal_value=(-1)**(n)*(2**(E-127))*(1+M)
    else:
        decimal_value=sp_value

    return decimal_value

def specialcases(n,E,M):
    if(E==0 and M==0):
        sp_value=0          #zero value
        sp_case=1
    elif(n==0 and E==255 and M==0):
        sp_value=float('inf')   #infinity value
        sp_case=1
    elif(n==1 and E==255 and M==0):
        sp_value=float('-inf')  #-infinity value
        sp_case=1
    elif(E==255 and M!=0):
        sp_value=float('nan')   #Not A Number
        sp_case=1
    else:
        sp_case=0               #not a special case
        sp_value=0
    return sp_value,sp_case

def bin_2_dec(bin_value):
    j=len(bin_value)
    sum=0
    for i in bin_value:         #convert binary integer into deciaml 
        sum=sum+2**(j-1)*i
        j=j-1
    return sum

def bin_2_frac(bin_value):
    sum=0
    j=-1;
    for i in bin_value:         #convert binnary fraction part into decimal
        sum=sum+(2**(j))*i
        j=j-1
    return sum

if __name__ == "__main__":

    #open binary output file for reading data
    file1= open("output_bin.txt",'r');
    #open file for writing decoded data
    file2= open("output_decoded.txt",'w')
    line=[]; real_value=[]; map_int=[];

    #read data from file and add into list strip() is used to remove \n
    for i in file1:
        line.append(i.strip());

    #map string into integer to access each bit of 32 bit input data
    for k in line:
        map_int.append(list(map(int,str(k))));
    
    #convert IEEE fp data into real value
    for x in map_int:
        decimal_data=decimalPointconvert((x));
        real_value.append(decimal_data);
        
    #write output data into file
    for j in real_value:
        file2.write(str(j)+'\n')

    #close file attributes
    file1.close();
    file2.close();

    
    
