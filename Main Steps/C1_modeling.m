function [Y_1d_n,Q1_I] = C1_modeling(time,time_step,N)
% Read reference simulation data
load('hurricane_dw.mat');

linear_factor = 0.8; % Y0 set to be 80% of max depth
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

for i = 1:1:3
    C1{i} = link('circle',{X{i},n{i},Sb{i},Q{end},YX{i},Y_up{i},D{i}}); % Construct each simple conduit
    C1_model{i} = model_link({C1{i}.p11},C1{i}.p12,{C1{i}.p21},C1{i}.p22); % Put each simple conduit as tranfer matrix
end
C1 = advanced_link_cascade({C1_model{1},C1{2},C1{3}}); % C1 is a cascade of three condutis
C1_model = C1;

% Orifice parameters at downstream
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

inflows = {J1_1inflow,J1_2inflow,J1_3inflow};
inflows = delay_inflow_ds(inflows,C1_model,time_step);

[Y_1d_n,Q1_I,Q1_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C1_model,OR1,CSO1,time_step,N);
end