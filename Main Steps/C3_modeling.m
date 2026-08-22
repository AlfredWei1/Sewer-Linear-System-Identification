function [Y_3d_n,Q3_I] = C3_modeling(time,time_step,N)
% Read reference simulation data
load('hurricane_dw.mat');

linear_factor = 0.8;
%Link C3:
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
Y_up{1} = YX{2};

for i = 1:1:3
    C3{i} = link('circle',{X{i},n{i},Sb{i},Q{1},YX{i},Y_up{i},D{i}});
    C3_model{i} = model_link({C3{i}.p11},C3{i}.p12,{C3{i}.p21},C3{i}.p22);
end
C3 = advanced_link_merging({C3_model{3},C3_model{2},C3{1}});
C3_model = C3;

% Orifice parameters at downstream
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

inflows = {J3_1inflow,J3_2inflow,J3_3inflow};
inflows = delay_inflow_ds(inflows,C3_model,time_step);

[Y_3d_n,Q3_I,Q3_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C3_model,OR3,CSO3,time_step,N);

end