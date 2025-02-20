clear;
clc;
close all;

% Remove Simulation I folder from Matlab path if it exists in the parent folder
currentFileLocation = fileparts(matlab.desktop.editor.getActiveFilename);
parent_path = fileparts(currentFileLocation);
cd(parent_path);
if exist("Simulation I",'dir')
    rmpath(genpath("Simulation I"));
end

% Add current simulation into working directory
addpath(genpath("Simulation II\"));
cd(currentFileLocation);

clear;
clc;

%% Read Data
format shortG;
load('hurricane_dw.mat');
N = length(J1_1inflow);
time_step = 300;
time = 0:time_step:N*time_step-time_step;

hours = seconds(time);
hours.Format = 'hh:mm';
set(0, 'DefaultLineLineWidth', 2.5);
set(0,'DefaultAxesFontName','Times')
set(0,'DefaultAxesFontSize',15)

%% Define parameters for equivalent conduit C1

linear_factor = 0.8;
%Link C1:
for index = 1:1:3
    cn = "C1_" + num2str(index); % cn stands for conduit name
    current_flow = eval(cn + 'flow');
    current_depth = eval(cn + 'downlevel');
    Qmax{index} = max(abs(current_flow)); %Maximum flow working around
    Qmin{index} = min(abs(current_flow)) + 0.1; %Minimum flow
    X{index} = 200; %length
    D{index} = 1;
    Sb{index} = 0.0008; %Bed slope
    n{index} = 0.013; %Manning Coefficients
    YX{index} = linear_factor*max(current_depth); % Downstream water depth
    if index == 1
        Y_up{index} = 0; % If we do not choose upstream depth, then the function computes the normal depth and use that
    else
        Y_up{index} = YX{index-1};
    end
    Q0{index} = mean(C1_3flow); % Average flow
    Q{index} = [Qmax{index},Qmin{index},Q0{index}];
end
Ydown_C1 = YX{end};

for i = 1:1:3
    C1{i} = link('circle',{X{i},n{i},Sb{i},Q{end},YX{i},Y_up{i},D{i}});
    C1_model{i} = model_link({C1{i}.p11},C1{i}.p12,{C1{i}.p21},C1{i}.p22);
end
C1 = advanced_link_cascade({C1_model{1},C1{2},C1{3}});
C1_model = C1;


Cd = 0.65;
A0 = 0.4*0.4;
g = 9.81;
Yfull = 0.4;
Z0 = 0;
OR1 = [Cd,A0,g,Yfull,Z0];
Cd = 0.65;
A0 = 0.4*0.4;
g = 9.81;
Yfull = 0.4;
Z0 = 0.5;
CSO1 = [Cd,A0,g,Yfull,Z0];

%% Define parameters for equivalent conduit C2
linear_factor = 1.2;
%Link C2:
clear YX Q0 Qmax Qmin X D Sb n Y_up Q;
for index = 1:1:17
    cn = "C2_" + num2str(index); % cn stands for conduit name
    current_flow = eval(cn + 'flow');
    current_depth = eval(cn + 'downlevel');
    Qmax{index} = max(abs(current_flow)); %Maximum flow working around
    Qmin{index} = min(abs(current_flow)) + 0.1; %Minimum flow
    if ismember(index,[16,17])
        X{index} = 500;
        D{index} = 1.5;
    else
        X{index} = 200; %length
        D{index} = 1;
    end
    Sb{index} = 0.0008; %Bed slope
    n{index} = 0.013; %Manning Coefficients
    YX{index} = linear_factor*max(current_depth); % Downstream water depth
    if ismember(index,[6,1,10,15])
        Y_up{index} = 0;
    elseif ismember(index,[4,5])
        Y_up{index} = 0;
    elseif ismember(index,[7])
        Y_up{index} = YX{4};
    else
        Y_up{index} = YX{index-1};
    end
    Q0{index} = mean(current_flow); % Average flow
    Q{index} = [Qmax{index},Qmin{index},Q0{index}];
end
Ydown_C2 = YX{end};

for i = 1:1:17
    C2{i} = link('circle',{X{i},n{i},Sb{i},Q{i},YX{i},Y_up{i},D{i}});
    C2_model{i} = model_link({C2{i}.p11},C2{i}.p12,{C2{i}.p21},C2{i}.p22);
end
TL = advanced_link_cascade({C2_model{1},C2{2},C2{3}});
TR = advanced_link_cascade({C2_model{6},C2{5},C2{4}});
M = advanced_link_merging({TL,TR,C2{7}});
M2 = advanced_link_cascade({M,C2{8},C2{9}});
BL = advanced_link_cascade({C2_model{10},C2{11},C2{12},C2{13}});
M3 = advanced_link_merging({M2,BL,C2{14}});
M4 = advanced_link_merging({M3,C2_model{15},C2{16}});
C2 = advanced_link_cascade({M4,C2{17}});
C2_model = C2;

Cd = 0.65;
A0 = 0.6*0.6;
g = 9.81;
Yfull = 0.6;
Z0 = 0;
OR2 = [Cd,A0,g,Yfull,Z0];
Cd = 0.65;
A0 = 0.4*0.4;
g = 9.81;
Yfull = 0.4;
Z0 = 0.7;
CSO2 = [Cd,A0,g,Yfull,Z0];
%% Define parameters for equivalent conduit C3

linear_factor = 0.8;
%Link C3:
clear YX Q0 Qmax Qmin X D Sb n Y_up Q;
for index = 1:1:3
    cn = "C3_" + num2str(index); % cn stands for conduit name
    current_flow = eval(cn + 'flow');
    current_depth = eval(cn + 'downlevel');
    Qmax{index} = max(abs(current_flow)); %Maximum flow working around
    Qmin{index} = min(abs(current_flow)) + 0.1; %Minimum flow
    X{index} = 200; %length
    D{index} = 1;
    Sb{index} = 0.0008; %Bed slope
    n{index} = 0.013; %Manning Coefficients
    YX{index} = linear_factor*max(current_depth); % Downstream water depth
    if index == 1
        Y_up{index} = 0;
    elseif ismember(index,[2,3])
        Y_up{index} = 0;
    end

    Q0{index} = mean(current_flow);
    Q{index} = [Qmax{index},Qmin{index},Q0{index}];
end
Ydown_C3 = YX{1};

for i = 1:1:3
    C3{i} = link('circle',{X{i},n{i},Sb{i},Q{1},YX{i},Y_up{i},D{i}});
    C3_model{i} = model_link({C3{i}.p11},C3{i}.p12,{C3{i}.p21},C3{i}.p22);
end
C3 = advanced_link_merging({C3_model{3},C3_model{2},C3{1}});
C3_model = C3;

Cd = 0.65;
A0 = 0.4*0.4;
g = 9.81;
Yfull = 0.4;
Z0 = 0;
OR3 = [Cd,A0,g,Yfull,Z0];
Cd = 0.65;
A0 = 0.4*0.4;
g = 9.81;
Yfull = 0.4;
Z0 = 0.5;
CSO3 = [Cd,A0,g,Yfull,Z0];

%% Compute the depth in the interceptor
linear_factor = 0.8;
%Link CI:
clear YX Q0 Qmax Qmin X D Sb n Y_up Q;
for index = 1:1:3
    cn = "CI_" + num2str(index); % cn stands for conduit name
    current_flow = eval(cn + 'flow');
    current_depth = eval(cn + 'downlevel');
    Qmax{index} = max(abs(current_flow)); %Maximum flow working around
    Qmin{index} = min(abs(current_flow)) + 0.1; %Minimum flow
    X{index} = 2000; %length
    D{index} = 1.5;
    Sb{index} = 0.0008; %Bed slope
    n{index} = 0.013; %Manning Coefficients
    YX{index} = linear_factor*max(current_depth); % Downstream water depth
    if index == 1
        Y_up{index} = 0;
    elseif ismember(index,[2,3])
        Y_up{index} = YX{index-1};
    end

    Q0{index} = mean(current_flow);
    Q{index} = [Qmax{index},Qmin{index},Q0{index}];
end
Ydown_interceptor = YX{end};

for i = 1:1:3
    CI{i} = link('circle',{X{i},n{i},Sb{i},Q{i},YX{i},Y_up{i},D{i}});
    CI_model{i} = model_link({CI{i}.p11},CI{i}.p12,{CI{i}.p21},CI{i}.p22);
    st = num2str(i) + "finsihed";
    disp(st)
end
CI = advanced_link_cascade({CI_model{1},CI{2},CI{3}});
CI_model = CI;

Cd = 0.65;
A0 = 0.7*0.7;
g = 9.81;
Yfull = 0.7;
Z0 = 0;
ORI = [Cd,A0,g,Yfull,Z0];

%% Construct Matrices
equiv_conduits = {C1_model,C2_model,C3_model};
interceptor = CI_model;
Ydown = {Ydown_C1,Ydown_C2,Ydown_C3,Ydown_interceptor};
orifice = {OR1,CSO1,OR2,CSO2,OR3,CSO3,ORI};
[A0,B0,A,B,E,xdelay,udelay,exoflow] = construct_ID_ct_system(equiv_conduits,interceptor,Ydown,orifice);
[equiv_K,equiv_L,equiv_K_CSO] = obtain_ID_KL(equiv_conduits,interceptor,Ydown,orifice);

for i = 1:1:length(exoflow)
    cons = exoflow{i};
    exoflow{i} = makeMinus(cons*ones(1,N));
end
% 

%% Construct Subcatchments
ha_to_m2 = 10000;
metric_unit = 1;
mmhr_to_ms = 2.77778e-7;


% For C1 subcatchments
sub_inflow_index_map = [1,2,3];
for index = 1:1:length(sub_inflow_index_map)
    Area{index} = 120*ha_to_m2;
    S{index} = 0.5*0.01;
    W{index} = 500;
    n{index} = 0.01;
    ds{index} = 0;
    alpha{index} = (metric_unit*W{index}*sqrt(S{index}))/(Area{index}*n{index});
    eval("Q0{index} = 0.4*max(J1_"+num2str(sub_inflow_index_map(index)) + "inflow);")
    d0{index} = (Q0{index}/(Area{index}*alpha{index}))^(3/5) + ds{index};
    beta{index} = (5/3)*Area{index}*alpha{index}*(d0{index}-ds{index})^(2/3);
end
M1 = nan(1,length(sub_inflow_index_map)+2);
for i = 1:1:length(sub_inflow_index_map)
    M1(i) = -beta{i}/Area{i};   
end
M1(length(sub_inflow_index_map)+1) = 0;
M1(length(sub_inflow_index_map)+2) = 0;
beta_C1 = beta;

% For C2 subcatchments
sub_inflow_index_map = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17];
for index = 1:1:length(sub_inflow_index_map)
    Area{index} = 25*ha_to_m2;
    S{index} = 0.5*0.01;
    W{index} = 1000;
    n{index} = 0.01;
    ds{index} = 0;
    alpha{index} = (metric_unit*W{index}*sqrt(S{index}))/(Area{index}*n{index});
    eval("Q0{index} = 0.4*max(J2_"+num2str(sub_inflow_index_map(index)) + "inflow);")
    d0{index} = (Q0{index}/(Area{index}*alpha{index}))^(3/5) + ds{index};
    beta{index} = (5/3)*Area{index}*alpha{index}*(d0{index}-ds{index})^(2/3);
end
M2 = nan(1,length(sub_inflow_index_map)+2);
for i = 1:1:length(sub_inflow_index_map)
    M2(i) = -beta{i}/Area{i};   
end
M2(length(sub_inflow_index_map)+1) = 0;
M2(length(sub_inflow_index_map)+2) = 0;
beta_C2 = beta;

% For C3 subcatchments
sub_inflow_index_map = [1,2,3];
for index = 1:1:length(sub_inflow_index_map)
    Area{index} = 80*ha_to_m2;
    S{index} = 0.5*0.01;
    W{index} = 500;
    n{index} = 0.01;
    ds{index} = 0;
    alpha{index} = (metric_unit*W{index}*sqrt(S{index}))/(Area{index}*n{index});
    eval("Q0{index} = 0.4*max(J3_"+num2str(sub_inflow_index_map(index)) + "inflow);")
    d0{index} = (Q0{index}/(Area{index}*alpha{index}))^(3/5) + ds{index};
    beta{index} = (5/3)*Area{index}*alpha{index}*(d0{index}-ds{index})^(2/3);
end
M3 = nan(1,length(sub_inflow_index_map)+2);
for i = 1:1:length(sub_inflow_index_map)
    M3(i) = -beta{i}/Area{i};   
end
M3(length(sub_inflow_index_map)+1) = 0;
M3(length(sub_inflow_index_map)+2) = 0;
beta_C3 = beta;

M = [M1,M2,M3];
M = [M,M];
M = [M,0];
M = diag(M);

%% Construct Rainfall
% Specify .dat delimit rules
DataStartLine = 4;
NumVariables = 2;
VariableNames  = {'Date_Time','rainfall'};
VariableWidths = [21,11] ;                                                  
DataType = {'string','double'}; 
opts = fixedWidthImportOptions('NumVariables',NumVariables,...
                               'DataLines',DataStartLine,...
                               'VariableNames',VariableNames,...
                               'VariableWidths',VariableWidths,...
                               'VariableTypes',DataType);

raintable = readtable('rainfall.dat',opts);
rainfall = raintable.rainfall';
rainfall = rainfall(1:end-1);
rainfall = mmhr_to_ms*rainfall;

rainfall_C1 = delay_rainfall_vector(rainfall,C1_model,time_step);
rainfall_C2 = delay_rainfall_vector(rainfall,C2_model,time_step);
rainfall_C3 = delay_rainfall_vector(rainfall,C3_model,time_step);
n1 = 3;
n2 = 17;
n3 = 3;
dirac_delta = @(t) 1*(t==1) + 0*(t~=1);
for i = 1:1:n1
    rainfall_C1{i} = @(t) time_step*beta_C1{i}*rainfall_C1{i}(t);
end
rainfall_C1{n1+1} = @(t) exoflow{1}(1)*dirac_delta(t);
rainfall_C1{n1+2} = @(t) exoflow{2}(1)*dirac_delta(t);
for i = 1:1:n2
    rainfall_C2{i} = @(t) time_step*beta_C2{i}*rainfall_C2{i}(t);
end
rainfall_C2{n2+1} = @(t) exoflow{3}(1)*dirac_delta(t);
rainfall_C2{n2+2} = @(t) exoflow{4}(1)*dirac_delta(t);
for i = 1:1:n3
    rainfall_C3{i} = @(t) time_step*beta_C3{i}*rainfall_C3{i}(t);
end
rainfall_C3{n3+1} = @(t) exoflow{5}(1)*dirac_delta(t);
rainfall_C3{n3+2} = @(t) exoflow{6}(1)*dirac_delta(t);

CI_123_delay = CI_model.taudk{1} + CI_model.taudk{2} + CI_model.taudk{3};
CI_123_delay = ceil(CI_123_delay/time_step);
rainfall_C1_I = delay_rainfall_constant(rainfall_C1(1:end-2),CI_123_delay);
rainfall_C1_I{end+1} = @(t) exoflow{1}(1)*dirac_delta(t);
rainfall_C1_I{end+1} = @(t) exoflow{2}(1)*dirac_delta(t);
CI_23_delay = CI_model.taudk{2} + CI_model.taudk{3};
CI_23_delay = ceil(CI_23_delay/time_step);
rainfall_C2_I = delay_rainfall_constant(rainfall_C2(1:end-2),CI_23_delay);
rainfall_C2_I{end+1} = @(t) exoflow{3}(1)*dirac_delta(t);
rainfall_C2_I{end+1} = @(t) exoflow{4}(1)*dirac_delta(t);
CI_3_delay = CI_model.taudk{3};
CI_3_delay = ceil(CI_3_delay/time_step);
rainfall_C3_I = delay_rainfall_constant(rainfall_C3(1:end-2),CI_3_delay);
rainfall_C3_I{end+1} = @(t) exoflow{5}(1)*dirac_delta(t);
rainfall_C3_I{end+1} = @(t) exoflow{6}(1)*dirac_delta(t);

final_element{1} = @(t) exoflow{7}(1)*dirac_delta(t);

temp = [rainfall_C1,rainfall_C2,rainfall_C3,rainfall_C1_I,rainfall_C2_I,rainfall_C3_I,final_element];

r = @(t) [];
for i = 1:1:length(temp)
    r = @(t) [r(t);temp{i}(t)];
end

%% Construct Augmented Model
[A,B,E] = augmented_matrix(A0,B0,A,B,E,xdelay,M,time_step);

%% Construct Stochastic Rainfall
%We add a gaussian to the actual rainfall density, then the disturbed rainfall will be
%our mean prediction to the rainfall

% For controller compute, we will only need the means and variance. We know
% the variance because we choose it, and the mean will be the disturbed
% rainfall.
N_w = size(E,2);
exoflow_indices = [4,5,23,24,28,29,33,34,52,53,57,58,59];

r_de = r;
sigma = mmhr_to_ms*2;
Sigma = zeros(N_w,N_w);
for i = 1:1:size(Sigma,1)
    if ismember(i,exoflow_indices)
        Sigma(i,i) = 0;
    else
        Sigma(i,i) = sigma;
    end
end

pred_err = @(t) mvnrnd(zeros(N_w,1),Sigma);
r_mean = @(t) r(t) + pred_err(t)';

Wbar = Sigma;
wbar = cell(1,N);
for t = 1:1:N
    wbar{t} = r_mean(t);
    for i = 1:1:N_w
        if ~ismember(i,exoflow_indices) && wbar{t}(i) < 0
            wbar{t}(i) = 0;
        end
    end
end

w0 = zeros(N_w,1);


%% Compute LQR controller

Q_small = diag([equiv_K_CSO,0.2]);
R_small = diag([equiv_L,0.01]);

Q = [];
R = [];
for i = 1:1:11
    Q = (1/(i+1))*blkdiag(Q,Q_small);
    R = (1/(i+1))*blkdiag(R,R_small);
end

Q = blkdiag(Q,zeros(N_w,N_w));

[K0,kappa0,K,kappa] = LQR_controller(A,B,E,Q,R,wbar,w0,Wbar);

% Next, remove unecesary elements from K0,kappa0,K,Kappa. Specifically, we
% remove rows of K, kappa that corresponds to inflows.
kappa0 = kappa0(1:4);
for i = 1:1:length(kappa)
    kappa{i} = kappa{i}(1:4);
end
K0 = K0(1:4,1:44);
for i = 1:1:length(K)
    K{i} = K{i}(1:4,1:44);
end

save("control_matrices.mat","K0","kappa0","K","kappa");

% % Start Commenting here
% sys_data{1} = A;
% sys_data{2} = B;
% sys_data{3} = E;
% sys_data{4} = M;
% control_data{1} = K0;
% control_data{2} = kappa0;
% control_data{3} = K;
% control_data{4} = kappa;
% simu_op{1} = time_step;
% simu_op{2} = N;
% u = @(t) zeros(4,1); % I.e., assume all OR's are full-open
% [Y,U] = ID_file_control(sys_data,simu_op,r,control_data,4);
% Y1 = Y(1,:);
% Y2 = Y(2,:);
% Y3 = Y(3,:);
% Y4 = Y(4,:);
% U1 = U(1,:);
% U2 = U(2,:);
% U3 = U(3,:);
% U4 = U(4,:);
% 
% figure;
% my_figure_2 = tiledlayout(2,2);
% sgtitle('Synthesized Linear System');
% set(gcf, 'Position',  [100, 100, 1200, 500])
% 
% nexttile;
% plot(hours,Y1,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,SU1level,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% legend('Linear Feedback','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^1(X,t)$','interpreter','latex');
% 
% nexttile;
% plot(hours,Y2,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,SU2level,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear Feedback','Linear Feedback','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^2(X,t)$','interpreter','latex');
% % 
% nexttile;
% plot(hours,Y3,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,SU3level,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear IDZ Model','Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^3(X,t)$','interpreter','latex');
% %
% nexttile;
% plot(hours,Y4,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,WWTPlevel,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear IDZ Model','Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^I(X,t)$','interpreter','latex');
% 
% %% Draw control
% figure;
% my_figure_2 = tiledlayout(2,2);
% sgtitle('Synthesized Linear System');
% set(gcf, 'Position',  [100, 100, 1200, 500])
% 
% nexttile;
% plot(hours,U1,'color',"#0072BD",'LineStyle','-.');
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% legend('Linear Feedback','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^1(X,t)$','interpreter','latex');
% 
% nexttile;
% plot(hours,U2,'color',"#0072BD",'LineStyle','-.');
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear Feedback','Linear Feedback','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^2(X,t)$','interpreter','latex');
% % 
% nexttile;
% plot(hours,U3,'color',"#0072BD",'LineStyle','-.');
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear IDZ Model','Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^3(X,t)$','interpreter','latex');
% %
% nexttile;
% plot(hours,U4,'color',"#0072BD",'LineStyle','-.');
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear IDZ Model','Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^I(X,t)$','interpreter','latex');
%% The nonlinear Torricelli's Law

function Q = torri_full(Y,W,data)

% Import Orifice Data
Cd = data(1);
A0 = data(2);
g = data(3);
Yfull = data(4);
Z0 = data(5);

% Adjust Area Opening according to W
A0 = W*A0;

% Compute Outflow
if Y <= Z0
        Q = 0;
    elseif Y > Z0 && Y < Z0 + (3/4)*W*Yfull
        CwL = sqrt(32/27)*(Cd*A0*sqrt(g))/(W*Yfull);
        Q = CwL*(Y-Z0)^(1.5);
    else
        He = Y-(Z0 + (W*Yfull)/2);
        Q = Cd*A0*sqrt(2*g*He);
end

end

function Q = torri(Y,data)

% Import Orifice Data
Cd = data(1);
A0 = data(2);
g = data(3);
Yfull = data(4);
Z0 = data(5);

constant = sqrt(32/27);
boundary = 0.25*(3*Yfull + 4*Z0);

% constant = 1;
% boundary = Yfull + Z0;

% Compute Outflow
if Y <= Z0
        Q = 0;
    elseif Y > Z0 && Y < boundary
        CwL = (Cd*A0*sqrt(g))/(Yfull);
        CwL = constant*CwL;
        Q = CwL*(Y-Z0)^(1.5);
    else
        He = Y-(Z0 + Yfull/2);
        Q = Cd*A0*sqrt(2*g*He);
end
end




