1. run random_no.py to generate random number in between -12 to 12  ---> output file - input_decoded.txt
2. run single_precision_fp.py to convert real no into IEEE single precision floating point number ---> output file - input_bin.txt
3. run ../testbench/sigmoid_tb.v to simulate result for given input ---> output file - output_bin.txt
4. run decimal_fp_convert.py to convert IEEE fp number into real no ---> output file - output_decoded.txt
5. run reference_op_sig.py to generate accurate result for given set of i/p ---> output file - refernce_output_sig.txt
6. run error_metrics.py to calculate error results ---> output file - error_metric.txt, error_data.txt

 