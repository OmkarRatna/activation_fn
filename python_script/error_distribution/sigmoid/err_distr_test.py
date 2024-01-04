import matplotlib.pyplot as plt
import numpy
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

density_sig4 = gaussian_kde(result_sig4)
density_sig4.covariance_factor = lambda : .25
density_sig4._compute_covariance()

density_sig8 = gaussian_kde(result_sig8)
density_sig8.covariance_factor = lambda : .25
density_sig8._compute_covariance()

density_sig12 = gaussian_kde(result_sig12)
density_sig12.covariance_factor = lambda : .25
density_sig12._compute_covariance()

density_sig16 = gaussian_kde(result_sig16)
density_sig16.covariance_factor = lambda : .25
density_sig16._compute_covariance()

density_cordic = gaussian_kde(result_cordic)
density_cordic.covariance_factor = lambda : .25
density_cordic._compute_covariance()
xs = numpy.linspace(-8, 8, 15000)

# Set the figure size
plt.figure(figsize=(14, 8))

# Make the chart
# We're actually building a line chart where x values are set all along the axis and y value are
# the corresponding values from the density function
plt.plot(xs,density_sig4(xs),color="#69b3a2")
plt.plot(xs,density_sig8(xs),color="black")
plt.plot(xs,density_sig12(xs),color="orange")
plt.plot(xs,density_sig16(xs),color="blue")
plt.plot(xs,density_cordic(xs),color="red")
plt.show()
sig4_file.close()
sig8_file.close()
sig12_file.close()
sig16_file.close()
cordic_file.close()
