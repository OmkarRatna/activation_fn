from random import random
from random import seed

max=12;
min=-12;
seed(2)
num=[];
for i in range(1,55000):
    norm_num=random()
    scaled_value=min+(norm_num*(max-min))
    num.append(scaled_value)

file1=open("input_decoded.txt","w+")
#file1.write(str(num))
#file1.writelines(str(num))
for line in num:
    file1.write(str(line) + '\n')
    #print(line)
file1.close()

