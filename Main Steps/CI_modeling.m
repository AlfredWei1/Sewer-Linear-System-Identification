function YI_n = CI_modeling(time,time_step,N,Q1_I,Q2_I,Q3_I)
% Read reference simulation data
load('hurricane_dw.mat');

linear_factor = 0.8;
%Link CI:
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

for i = 1:1:3
    CI{i} = link('circle',{X{i},n{i},Sb{i},Q{i},YX{i},Y_up{i},D{i}});
    CI_model{i} = model_link({CI{i}.p11},CI{i}.p12,{CI{i}.p21},CI{i}.p22);
    st = num2str(i) + "finsihed";
    disp(st)
end
CI = advanced_link_cascade({CI_model{1},CI{2},CI{3}});
CI_model = CI;

% Orifice parameters at downstream
Cd = 0.65;
A0 = 0.7*0.7;
g = 9.81;
Yfull = 0.7;
Z0 = 0;
ORI = [Cd,A0,g,Yfull,Z0];

inflows = {Q1_I,Q2_I,Q3_I};
inflows = delay_inflow_ds(inflows,CI_model,time_step);

[YI_n,QI] = ds_capital_nonlinear_1o_simulation(inflows,CI_model,ORI,time_step,N);

end