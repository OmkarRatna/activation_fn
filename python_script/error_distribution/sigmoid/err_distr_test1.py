import matplotlib.pyplot as plt
import numpy
import seaborn as sns
from scipy.stats import gaussian_kde
err_sig4=[];err_sig8=[];err_sig12=[];err_sig16=[];err_cordic=[];
result=[];
sig4_file=open("error_data_sig4.txt")
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


sns.kdeplot(result_sig4)
#sns.kdeplot(result_sig8)
sns.kdeplot(result_cordic)
# Show the plot
plt.xlim(-8,8)
plt.show()
sig4_file.close()
sig8_file.close()
sig12_file.close()
sig16_file.close()
cordic_file.close()
