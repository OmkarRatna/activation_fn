clc;
clear;

sys_x4_tmac_1 = readmatrix("/home/iiit-1/mahati/out_files/cordic_posit/bfloat_16/tanh/bf16_new_tanh_1212_new.txt");


%%% FP32
% Exact_x4_tmac_1 = [sys_x4_tmac_1(1:550000,3)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:550000,4)];

%%% FP32
% Exact_x4_tmac_1 = [sys_x4_tmac_1(1:27651,3)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:27651,4)];

%%% BF16
%%% -12 to 12
Exact_x4_tmac_1 = [sys_x4_tmac_1(1:26157,3)];
Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:26157,4)];

%%% Softmax
% Exact_x4_tmac_1 = [sys_x4_tmac_1(1:1500000,1)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:1500000,2)];

%%% FP16

%%% -1 to 1
% Exact_x4_tmac_1 = [sys_x4_tmac_1(1:14337,3);sys_x4_tmac_1(30722:45058,3)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:14337,4);sys_x4_tmac_1(30722:45058,4)];

%%% -12 to 12
% Exact_x4_tmac_1 = [sys_x4_tmac_1(1:17921,3);sys_x4_tmac_1(30722:48642,3)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(1:17921,4);sys_x4_tmac_1(30722:48642,4)];




%%% Posit12_1 & Posit_12_2

%%% -1 to 1
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1026,2);sys_x4_tmac_1(3073:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1026,3);sys_x4_tmac_1(3073:4096,3)];

%%% -12 to 12
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1730,2);sys_x4_tmac_1(2369:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1730,3);sys_x4_tmac_1(2369:4096,3)];


%%% Posit12_2

%%% -1 to 1
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1026,2);sys_x4_tmac_1(3073:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1026,3);sys_x4_tmac_1(3073:4096,3)];

%%% -12 to 12
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1474,2);sys_x4_tmac_1(2625:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1474,3);sys_x4_tmac_1(2625:4096,3)];



%%% Posit12_3

%%% -1 to 1
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1026,2);sys_x4_tmac_1(3073:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1026,3);sys_x4_tmac_1(3073:4096,3)];
%%% -12 to 12
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:1250,2);sys_x4_tmac_1(2849:4096,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:1250,3);sys_x4_tmac_1(2849:4096,3)];


%%% Posit10_1

%%% -1 to 1
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:258,2);sys_x4_tmac_1(769:1024,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:258,3);sys_x4_tmac_1(769:1024,3)];
%%% -12 to 12
% Exact_x4_tmac_1 = [sys_x4_tmac_1(2:434,2);sys_x4_tmac_1(593:1024,2)];
% Apprx_x4_tmac_1 = [sys_x4_tmac_1(2:434,3);sys_x4_tmac_1(593:1024,3)];









Error = Apprx_x4_tmac_1-Exact_x4_tmac_1;
ME_x4_tmac_1 = sum(Error)/numel(Apprx_x4_tmac_1);
MAE_x4_tmac_1 = sum(abs(Error))/numel(Apprx_x4_tmac_1);
min_x4_tmac_1 = min(Error);
max_x4_tmac_1 = max(Error);
error_rate_x4_tmac_1 = nnz(Error)/numel(Apprx_x4_tmac_1)*100;
std_dev_x4_tmac_1 = std(Error);
std_dev_my_x4_tmac_1 = sqrt(sum((Error-ME_x4_tmac_1).^2)/numel(Apprx_x4_tmac_1));
% abs_std_dev_x4_tmac_1 = std(abs(Error));
% abs_std_dev_my_x4_tmac_1 = sqrt(sum((abs(Error)-MAE_x4_tmac_1).^2)/numel(Apprx_x4_tmac_1));
ERMS_x4_tmac_1 = rms(Error);
NoEB_x4_tmac_1 = 32 - log2(1+ERMS_x4_tmac_1); %% Here 32 represents total number of output bits
Q1_x4_tmac_1 = quantile(Error,0.25);
Q2_x4_tmac_1 = quantile(Error,0.50);
Q3_x4_tmac_1 = quantile(Error,0.75);
IQR_x4_tmac_1 = Q3_x4_tmac_1-Q1_x4_tmac_1;

% Error_Metric = [ME_x4_tmac_1 min_x4_tmac_1 max_x4_tmac_1 error_rate_x4_tmac_1 std_dev_x4_tmac_1 ERMS_x4_tmac_1 NoEB_x4_tmac_1 Q1_x4_tmac_1 Q2_x4_tmac_1 Q3_x4_tmac_1 IQR_x4_tmac_1;
%                ]

% disp(['ME:',num2str(ME_x4_tmac_1)]);
% disp(['Min:',num2str(min_x4_tmac_1)]);
% disp(['Max:',num2str(max_x4_tmac_1)]);
% disp(['ER:',num2str(error_rate_x4_tmac_1)]);
% disp(['std_dev:',num2str(std_dev_x4_tmac_1)]);
% disp(['ERMS:',num2str(ERMS_x4_tmac_1)]);
% disp(['NoEB:',num2str(NoEB_x4_tmac_1)]);
% disp(['Q1:',num2str(Q1_x4_tmac_1)]);
% disp(['Q2:',num2str(Q2_x4_tmac_1)]);
% disp(['Q3:',num2str(Q3_x4_tmac_1)]);
% disp(['IQR:',num2str(IQR_x4_tmac_1)]);




disp([num2str(ME_x4_tmac_1)]);
disp([num2str(min_x4_tmac_1)]);
disp([num2str(max_x4_tmac_1)]);
disp([num2str(error_rate_x4_tmac_1)]);
disp([num2str(std_dev_x4_tmac_1)]);
disp([num2str(ERMS_x4_tmac_1)]);
disp([num2str(NoEB_x4_tmac_1)]);
disp([num2str(Q1_x4_tmac_1)]);
disp([num2str(Q2_x4_tmac_1)]);
disp([num2str(Q3_x4_tmac_1)]);
disp([num2str(IQR_x4_tmac_1)]);
