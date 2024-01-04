#to calculate various error metrics
#list of metric
import math 
import statistics as stat
#Function that Calculate Root Mean Square 
def rmsValue(arr, n):
   
    square = 0
    mean = 0.0
    root = 0.0
     
    #Calculate square
    for i in range(0,n):
        square += (arr[i]**2)
     
    #Calculate Mean 
    mean = (square / (float)(n))
     
    #Calculate Root
    root = math.sqrt(mean)
     
    return root
if __name__=='__main__':

    file1= open("reference_output_tanhx.txt",'r')
    #file1=open("reference_output_sig.txt",'r')
    #file2= open("output_decoded.txt",'r')

    file2=open("tanh_omkar_outputs_decoded.txt",'r')
    #file2=open("sigmoid_omkar_outputs_decoded.txt",'r')

    file3= open("error_metric.txt",'w')
    file4= open("error_data.txt",'w')
    refer_data=[]; out_data=[]; ERR=[]; ERR_sort=[];
    err_metrics=[];
    for i in file1:
        refer_data.append(i)

    for j in file2:
        out_data.append(j)

    for k in range(len(refer_data)):
        ERR.append(float(refer_data[k])-float(out_data[k]))

    ERR_sort=ERR.copy()
    ERR_sort.sort()
    n=0
    for i in ERR:
        if(i!=0):
            n=n+1
    ER=(n*100)/len(ERR)
    ERR_length=len(ERR)
    std_dev=stat.stdev(ERR)    
    abs_err=[abs(ele) for ele in ERR]
    MAE=sum(abs_err)/len(ERR)
    ME=sum(ERR)/len(ERR)
    MIN=min(ERR)
    MAX=max(ERR)
    ERMS=rmsValue(ERR,len(ERR))
    NoEB=32-math.log2(1+ERMS)
    Q1=stat.median(ERR_sort[0:math.floor((ERR_length/2))])
    Q2=stat.median(ERR_sort);
    Q3=stat.median(ERR_sort[math.floor((ERR_length/2)+1):(ERR_length)])
    IQR=Q3-Q1;
    err_metrics=["MAE: "+str(MAE)+"\n","ME: "+str(ME)+"\n","MIN_ERROR: "+str(MIN)+"\n","MAX_ERROR: "+str(MAX)+"\n","STD_DEV: "+str(std_dev)+"\n","ERMS: "+str(ERMS)+"\n" + "NoEB: "+str(NoEB)+"\n"+"Q1: "+str(Q1)+"\n"+"Q2 "+str(Q2)+"\n"+"Q3: "+str(Q3)+"\n"+"IQR: "+str(IQR)+"\n"]
    for j in err_metrics:
        file3.write(j)

    for i in ERR:
        file4.write(str(i)+'\n')
    file1.close();
    file2.close();
    file3.close();
    file4.close();



