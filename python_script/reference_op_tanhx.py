#calculating golden reference output for given input
#function- tanhx
import math
file1= open("input_decoded.txt",'r')
file2= open("reference_output_tanhx.txt",'w')
refer_op=[];

#calculating tanhx=exp(x)-exp(-x)/exp(x)+exp(-x)
for i in file1:
    ap=(math.exp(float(i))-math.exp(-1*float(i)))/(math.exp(float(i))+math.exp(-1*float(i)))
    refer_op.append(ap)

#writing tanhx value in reference_output.txt
for j in refer_op:
    file2.write(str(j)+"\n")

#closing file attributes
file1.close()
file2.close()




