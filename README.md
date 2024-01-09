This paper discusses on applying clustering scheme to realize 
two of the activation functions. Two of the most popular activation functions Tanh, and Sigmoid were designed using this novel approach. The novel approach extracts the clusters that maps to 
different non-linear segments on the input vector, and generates a output for the same cluster points. The cluster method is similar to the piece-wise-linear approach, however it betters the latter by grouping 
closer output points to one, thereby saving the computation involved to generate different outputs for a given input. 
The work explores four different cluster segments and characterizes the error distribution for all of them, and then compares the hardware parameters with the most efficient state-of-the-art~(SOTA) implementation.

DIRECTORY STRUCTURE -
tanhx_verilog : verilog code for tanhx implementation
sigmoid_verilog : Verilog code for sigmoid implementation
Single_Float_Adder : verilog code for single precision full adder
testbench : verilog code for simulation of both designs
python_script : python script for error analysis
mahati_code : verilog code for cordic based Implemenatation of activation functions
genus : scripts to carry out synthesis
figures : diagram of activation functions 
