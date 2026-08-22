function [Y_2d_n,Q2_I] = C2_modeling(time,time_step,N)
% Read reference simulation data
load('hurricane_dw.mat');

% Link C2
linear_factor = 0.8;
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

for i = 1:1:17
    C2{i} = link('circle',{X{i},n{i},Sb{i},Q{i},YX{i},Y_up{i},D{i}}); % Construct each simple conduit
    C2_model{i} = model_link({C2{i}.p11},C2{i}.p12,{C2{i}.p21},C2{i}.p22); % Put each simple conduit as tranfer matrix
end
% Now we follow the topology of C2, starting from upstream
TL = advanced_link_cascade({C2_model{1},C2{2},C2{3}});
TR = advanced_link_cascade({C2_model{6},C2{5},C2{4}});
M = advanced_link_merging({TL,TR,C2{7}});
M2 = advanced_link_cascade({M,C2{8},C2{9}});
BL = advanced_link_cascade({C2_model{10},C2{11},C2{12},C2{13}});
M3 = advanced_link_merging({M2,BL,C2{14}});
M4 = advanced_link_merging({M3,C2_model{15},C2{16}});
C2 = advanced_link_cascade({M4,C2{17}});
C2_model = C2;

% Orifice parameters at downstream
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

inflows = {J2_1inflow,J2_2inflow,J2_3inflow,J2_7inflow,J2_6inflow,J2_5inflow,...
            J2_4inflow,J2_8inflow,J2_9inflow,J2_14inflow,J2_13inflow,J2_12inflow,...
            J2_11inflow,J2_10inflow,J2_16inflow,J2_15inflow,J2_17inflow};
inflows = delay_inflow_ds(inflows,C2_model,time_step);

[Y_2d_n,Q2_I,Q2_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C2_model,OR2,CSO2,time_step,N);

end