file1= open("tanhx_k4/error_data_k4.txt",'r')
file2= open("tanhx_k12/error_data_k12.txt",'r')

err_k4=[]; err_k12=[];
float_err_k4=[]; float_err_k12=[];
for i in file1:
    err_k4.append(i)
for i in file2:
    err_k12.append(i)

for j in err_k4:
    float_err_k4.append(float(j))
for j in err_k12:
    float_err_k12.append(float(j))
a12=[abs(ele) for ele in float_err_k4]
a23=[abs(ele) for ele in float_err_k12]

#for i in range(len(a12)):
 #   if(a12[i]<a23[i]):
  #      print("index:"+ str(i)+"k=4 :" + str(a12[i])+"k=8 :" + str(a23[i]))
m=0


print(m)
a1= sum(a12)
a2= sum(a23)

file1.close();
file2.close();
