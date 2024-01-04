import matplotlib.pyplot as plt
import seaborn as sns
import numpy
from scipy.stats import norm
err_sig4=[];err_sig8=[];err_sig12=[];err_sig16=[];err_cordic=[];

result=[];
j=0;
sig4_file=open('error_data_sig4.txt')
sig8_file=open('error_data_sig8.txt')
sig12_file=open('error_data_sig12.txt')
sig16_file=open('error_data_sig16.txt')
cordic_file=open('error_data_cordic_sig.txt')

for i in sig4_file:
    err_sig4.append((float(i.strip()))*100);
for i in sig8_file:
    err_sig8.append((float(i.strip()))*100);
for i in sig12_file:
    err_sig12.append((float(i.strip()))*100);
for i in sig16_file:
    err_sig16.append((float(i.strip()))*100);
for i in cordic_file:
    err_cordic.append((float(i.strip()))*100);


result_sig4=numpy.array(err_sig4)
result_sig8=numpy.array(err_sig8)
result_sig12=numpy.array(err_sig12)
result_sig16=numpy.array(err_sig16)
result_cordic=numpy.array(err_cordic)


#z=sns.histplot(x=result_sig4,bins=70,kde=True,stat='density', common_norm=False,fill=False ,color='maroon')
#z=sns.histplot(x=result_sig8, bins=70,kde=True,stat='density', common_norm=False,fill=False,color='blue')
#z=sns.histplot(x=result_sig12, bins=70,kde=True,stat='density',common_norm=False,fill=False, color='red')
#z=sns.histplot(x=result_sig16, bins=70,kde=True,stat='density',common_norm=False,fill=False, color='purple')
#z=sns.histplot(x=result_cordic, bins=10,kde=True,stat='density',common_norm=False,fill=False, color='orange')

z=sns.histplot(x=result_sig4,bins=70,kde=True,fill=False ,color='maroon',label='K=4')
z=sns.histplot(x=result_sig8, bins=70,kde=True,fill=False,color='blue',label='K=8')
z=sns.histplot(x=result_sig12, bins=70,kde=True,fill=False, color='red',label='K=12')
z=sns.histplot(x=result_sig16, bins=70,kde=True,fill=False, color='purple',label='K=16')
z=sns.histplot(x=result_cordic, bins=10,kde=True,fill=False, color='orange',label='cordic')




plt.xlim(-8,8)           
plt.grid(axis='y', alpha=0.25)
plt.grid(axis='x', alpha=0.25)
plt.xlabel('Error in %',fontsize=15)
plt.ylabel('Frequency',fontsize=15)
plt.xticks(fontsize=15)
plt.yticks(fontsize=15)
plt.ylabel('Frequency',fontsize=15)
plt.legend()
#plt.title('Normal Distribution Histogram',fontsize=15)
plt.show()
sig4_file.close()
sig8_file.close()
sig12_file.close()
sig16_file.close()
cordic_file.close()
