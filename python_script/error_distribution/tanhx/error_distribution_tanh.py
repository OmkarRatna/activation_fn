import matplotlib.pyplot as plt
import seaborn as sns
import numpy

err_tanh4=[];err_tanh8=[];err_tanh12=[];err_tanh16=[];err_cordic=[];

result=[];
j=0;
tanh4_file=open('error_data_tanh4.txt')
tanh8_file=open('error_data_tanh8.txt')
tanh12_file=open('error_data_tanh12.txt')
tanh16_file=open('error_data_tanh16.txt')
cordic_file=open('error_data_cordic_tanh.txt')

for i in tanh4_file:
    err_tanh4.append((float(i.strip()))*100);
for i in tanh8_file:
    err_tanh8.append((float(i.strip()))*100);
for i in tanh12_file:
    err_tanh12.append((float(i.strip()))*100);
for i in tanh16_file:
    err_tanh16.append((float(i.strip()))*100);
for i in cordic_file:
    err_cordic.append((float(i.strip()))*100);


result_tanh4=numpy.array(err_tanh4)
result_tanh8=numpy.array(err_tanh8)
result_tanh12=numpy.array(err_tanh12)
result_tanh16=numpy.array(err_tanh16)
result_cordic=numpy.array(err_cordic)

z=sns.histplot(x=result_tanh4, bins=50,kde=True,fill=False, color='maroon',label='K=4')
z=sns.histplot(x=result_tanh8, bins=50,kde=True,fill=False, color='blue',label='K=8')
z=sns.histplot(x=result_tanh12, bins=50,kde=True,fill=False, color='red',label='K=12')
z=sns.histplot(x=result_tanh16, bins=50,kde=True,fill=False, color='purple',label='K=16')
z=sns.histplot(x=result_cordic, bins=70,kde=True,fill=False, color='orange',label='cordic')

plt.xlim(-8, 8)


plt.grid(axis='y', alpha=0.25)
plt.grid(axis='x', alpha=0.25)
plt.xlabel('Error in %',fontsize=15)
plt.ylabel('Frequency',fontsize=15)
plt.xticks(fontsize=15)
plt.yticks(fontsize=15)
plt.ylabel('Frequency',fontsize=15)
#plt.title('Normal Distribution Histogram',fontsize=15)
plt.legend()
plt.show()
tanh4_file.close()
tanh8_file.close()
tanh12_file.close()
tanh16_file.close()
cordic_file.close()
