clear;
clc;
close all;

format shortG

currentFileLocation = fileparts(matlab.desktop.editor.getActiveFilename);
cd(currentFileLocation);
addpath(genpath("./Identification/"))

%% Read Data
load('hurricane_dw.mat');
N = length(J1_1inflow);
time_step = 5;
time = 0:time_step:N*time_step-time_step;

hours = seconds(time);
hours.Format = 'hh:mm';
set(0, 'DefaultLineLineWidth', 2.5);
set(0,'DefaultAxesFontName','Times')
set(0,'DefaultAxesFontSize',12)

% raintable = readtable('rainfall.dat');
% rainfall = construct_rainfall(raintable,N);
% 
% figure;
% my_figure_rainfall = tiledlayout(2,2);
% set(gcf, 'Position',  [100, 100, 1100, 500])
% 
% nexttile;
% plot(hours,rainfall,'color',"#0072BD");
% title('Rainfall','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex');
% ylabel("Rainfall (mm/hr)",'interpreter','latex');
% grid on;
% 
% inflows = {J1inflow,J2inflow,J3inflow};
% 
% if length(inflows) == 0
% else
%     for i = 1:1:length(inflows)
%         nexttile;
%         plot(hours,inflows{i},'color',"#0072BD");
%         title_name = "Lateral Inflow at Upstream of Conduit" + " " + num2str(i);
%         title(title_name,'interpreter','latex');
%         xlabel('Time(hh:mm)','interpreter','latex');
%         ylabel("Inflow (m$^3$/s)",'interpreter','latex');
%         grid on;
%     end
% end



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

inflows = {J1_1inflow,J1_2inflow,J1_3inflow};
inflows = delay_inflow_ds(inflows,C1_model,time_step);

[Y_1d_n,Q1_I,Q1_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C1_model,OR1,CSO1,time_step,N);

h = 0.01;
OR1_gain = (torri(YX{end}+h,OR1) - torri(YX{end},OR1))/h;
CSO1_gain = (torri(YX{end}+h,CSO1) - torri(YX{end},CSO1))/h;
L1 = (torri_full(YX{end}+h,0.99,OR1) - torri_full(YX{end},0.99,OR1))/h;

% % Yin = 0:0.01:1;
% % cons = [];
% % % This portion is for OR1 only
% % for i = 1:1:length(Yin)
% %     OR1_flow_p = torri(Yin(i),OR1);
% %     OR1_gain_p = (torri(Yin(i)+h,OR1) - torri(Yin(i),OR1))/h;
% %     cons = [cons, OR1_flow_p - OR1_gain_p*Yin(i)];
% % end
% % 
% % % This portion is for CSO1 sand OR1 both present
% % for i = 1:1:length(Yin)
% %     OR1_flow_p = torri(Yin(i),OR1);
% %     OR1_gain_p = (torri(Yin(i)+h,OR1) - torri(Yin(i),OR1))/h;
% %     CSO1_flow_p = torri(Yin(i),CSO1);
% %     CSO1_gain_p = (torri(Yin(i)+h,CSO1) - torri(Yin(i),CSO1))/h;
% %     cons = [cons, OR1_flow_p - OR1_gain_p*Yin(i) + CSO1_flow_p - CSO1_gain_p*Yin(i)];
% % end
% % 
% % figure;
% % plot(Yin,cons)

[A1,B1,E1,C1,D1,F1] = equivCond_matrix(C1_model,CSO1_gain,OR1_gain,L1,1);
C1_matrices = link_matrices(A1,B1,E1,C1,D1,F1,OR1_gain,0);
[A1,B1,E1,C1,D1,F1] = discretize_matrices(A1,B1,E1,C1,D1,F1,time_step);

op_flow = Q0{end};
op_depth = YX{end};
CSO1_flow = torri(YX{end},CSO1);
OR1_flow = torri(YX{end},OR1);
inflows_C1 = {makeMinus(J1_1inflow),makeMinus(J1_2inflow),makeMinus(J1_3inflow), makeMinus((OR1_flow - OR1_gain*op_depth)*ones(1,N)), makeMinus((CSO1_flow - CSO1_gain*op_depth)*ones(1,N))};
inflows_C1 = delay_inflow(inflows_C1,C1_model,time_step);
inflows = inflows_C1;
K_constant = CSO1_gain + OR1_gain;
[Y1_linear,x1linear] = ds_capital_linear_2o_simulation(A1,B1,E1,C1,D1,F1,K_constant,inflows,C1_model,time_step,op_flow,op_depth,N);

%% Define parameters for equivalent conduit C2
% linear_factor = 0.8;
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

inflows = {J2_1inflow,J2_2inflow,J2_3inflow,J2_7inflow,J2_6inflow,J2_5inflow,...
            J2_4inflow,J2_8inflow,J2_9inflow,J2_14inflow,J2_13inflow,J2_12inflow,...
            J2_11inflow,J2_10inflow,J2_16inflow,J2_15inflow,J2_17inflow};
inflows = delay_inflow_ds(inflows,C2_model,time_step);

[Y_2d_n,Q2_I,Q2_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C2_model,OR2,CSO2,time_step,N);

h = 0.01;
OR2_gain = (torri(YX{end}+h,OR2) - torri(YX{end},OR2))/h;
CSO2_gain = (torri(YX{end}+h,CSO2) - torri(YX{end},CSO2))/h;
L2 = (torri_full(YX{end}+h,0.99,OR2) - torri_full(YX{end},0.99,OR2))/h;

[A2,B2,E2,C2,D2,F2] = equivCond_matrix(C2_model,CSO2_gain,OR2_gain,L2,1);
C2_matrices = link_matrices(A2,B2,E2,C2,D2,F2,OR2_gain,0);
[A2,B2,E2,C2,D2,F2] = discretize_matrices(A2,B2,E2,C2,D2,F2,time_step);

op_flow = Q0{1};
op_depth = YX{end};
CSO2_flow = torri(YX{end},CSO2);
OR2_flow = torri(YX{end},OR2);
inflows_C2 = {makeMinus(J2_1inflow),makeMinus(J2_2inflow),makeMinus(J2_3inflow),...
              makeMinus(J2_7inflow),makeMinus(J2_6inflow),makeMinus(J2_5inflow),...
            makeMinus(J2_4inflow),makeMinus(J2_8inflow),makeMinus(J2_9inflow),...
            makeMinus(J2_14inflow),makeMinus(J2_13inflow),makeMinus(J2_12inflow),...
            makeMinus(J2_11inflow),makeMinus(J2_10inflow),makeMinus(J2_16inflow),...
            makeMinus(J2_15inflow),makeMinus(J2_17inflow),...
            makeMinus((OR2_flow - OR2_gain*op_depth)*ones(1,N)), makeMinus((CSO2_flow - CSO2_gain*op_depth)*ones(1,N))};
inflows_C2 = delay_inflow(inflows_C2,C2_model,time_step);
inflows = inflows_C2;
K_constant = CSO2_gain + OR2_gain;
[Y2_linear,x2linear] = ds_capital_linear_2o_simulation(A2,B2,E2,C2,D2,F2,K_constant,inflows,C2_model,time_step,op_flow,op_depth,N);
%% Define parameters for equivalent conduit C3

% linear_factor = 0.8;
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
Y_up{1} = YX{2};

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

inflows = {J3_1inflow,J3_2inflow,J3_3inflow};
inflows = delay_inflow_ds(inflows,C3_model,time_step);

[Y_3d_n,Q3_I,Q3_CSO] = ds_capital_nonlinear_2o_simulation(inflows,C3_model,OR3,CSO3,time_step,N);

h = 0.01;
OR3_gain = (torri(YX{1}+h,OR3) - torri(YX{1},OR3))/h;
CSO3_gain = (torri(YX{1}+h,CSO3) - torri(YX{1},CSO3))/h;
L3 = (torri_full(YX{1}+h,0.99,OR3) - torri_full(YX{1},0.99,OR3))/h;

[A3,B3,E3,C3,D3,F3] = equivCond_matrix(C3_model,CSO3_gain,OR3_gain,L3,1);
C3_matrices = link_matrices(A3,B3,E3,C3,D3,F3,OR3_gain,0);
[A3,B3,E3,C3,D3,F3] = discretize_matrices(A3,B3,E3,C3,D3,F3,time_step);

op_flow = Q0{1};
op_depth = YX{1};
CSO3_flow = torri(YX{1},CSO3);
OR3_flow = torri(YX{1},OR3);
ex_OR3_flow = OR3_flow - OR3_gain*op_depth;
ex_CSO3_flow = CSO3_flow - CSO3_gain*op_depth;
inflows_C3 = {makeMinus(J3_1inflow),makeMinus(J3_2inflow),makeMinus(J3_3inflow), makeMinus(ex_OR3_flow*ones(1,N)), makeMinus(ex_CSO3_flow*ones(1,N))};
inflows_C3 = delay_inflow(inflows_C3,C3_model,time_step);
inflows = inflows_C3;
K_constant = CSO3_gain + OR3_gain;
[Y3_linear,x3linear] = ds_capital_linear_2o_simulation(A3,B3,E3,C3,D3,F3,K_constant,inflows,C3_model,time_step,op_flow,op_depth,N);

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

inflows = {Q1_I,Q2_I,Q3_I};
inflows = delay_inflow_ds(inflows,CI_model,time_step);

[YI_n,QI] = ds_capital_nonlinear_1o_simulation(inflows,CI_model,ORI,time_step,N);

h = 0.01;
ORI_gain = (torri(YX{end}+h,ORI) - torri(YX{end},ORI))/h;
LI = (torri_full(YX{end}+h,0.99,ORI) - torri_full(YX{end},0.99,ORI))/h;

equiv_matrices = {C1_matrices,C2_matrices,C3_matrices};
[AI,BI,EI,CI,DI,FI] = interceptor_matrix(CI_model,ORI_gain,LI,equiv_matrices,1);
[AI,BI,EI,CI,DI,FI] = discretize_matrices(AI,BI,EI,CI,DI,FI,time_step);

op_flow = Q0{end};
op_depth = YX{end};
ORI_flow = torri(YX{end},ORI);
inflows = [inflows_C1,inflows_C2, inflows_C3,{makeMinus((ORI_flow - ORI_gain*op_depth)*ones(1,N))}];
inflows = delay_inflow_interceptor(inflows,{C1_model,C2_model,C3_model},CI_model,time_step);
K_constant = ORI_gain;
equiv_states = {makeMinus(x1linear),makeMinus(x2linear),makeMinus(x3linear)};
YI_linear = ds_capital_linear_1o_simulation(AI,BI,EI,CI,DI,FI,K_constant,inflows,equiv_states,CI_model,equiv_matrices,time_step,op_flow,op_depth,N);

%% Plot the results

print_model_link_parameters(C1_model,'C1')
print_model_link_parameters(C2_model,'C2')
print_model_link_parameters(C3_model,'C3')
print_model_link_parameters(CI_model,'CI')

figure;
T = tiledlayout(2,2);
T.TileSpacing = 'compact';
T.Padding = 'compact';
sgtitle('Synthesized Linear System','interpreter','latex','fontSize',16);
set(gcf, 'Position',  [100, 100, 1300, 500])
start_time_1 = hours((6*60*60)/time_step);
start_time_1.Format = 'hh:mm';
end_time_1 = hours((24*60*60)/time_step);
end_time_1.Format = 'hh:mm';
start_time_2 = hours((24*60*60)/time_step);
start_time_2.Format = 'hh:mm';
end_time_2 = hours((47.8*60*60)/time_step);
end_time_2.Format = 'hh:mm';


t1 = tiledlayout(T,1,2);
t1.TileSpacing = 'compact';
t1.Padding = 'compact';
t1.Layout.Tile = 1;
nexttile(t1);
plot(hours,Y_1d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y1_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU1level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(Y1_linear)]));
ylabel('Water Depth (m)','interpreter','latex');
title('$Y^1_X(t)$ Peak','interpreter','latex');
xlim([start_time_1 end_time_1]);
ylim([0,inf]);
nexttile(t1);
plot(hours,Y_1d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y1_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU1level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(Y1_linear)]));
set(gca,'YAxisLocation','right')
title('$Y^1_X(t)$ Steady State','interpreter','latex');
xlim([start_time_2 end_time_2]);
ylim([0,inf]);

t2 = tiledlayout(T,1,2);
t2.TileSpacing = 'compact';
t2.Padding = 'compact';
t2.Layout.Tile = 2;
nexttile(t2);
plot(hours,Y_2d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y2_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU2level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(SU2level) max(Y2_linear)]));
title('$Y^2_X(t)$ Peak','interpreter','latex');
xlim([start_time_1 end_time_1]);
ylim([0,inf]);
nexttile(t2);
plot(hours,Y_2d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y2_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU2level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(SU2level) max(Y2_linear)]));
set(gca,'YAxisLocation','right')
title('$Y^2_X(t)$ Steady State','interpreter','latex');
xlim([start_time_2 end_time_2]);
ylim([0,inf]);
h = legend('Nonlinear Feedback','Linear Feedback','SWMM Simulation','Orientation', 'Horizontal','Location','north');

t3 = tiledlayout(T,1,2);
t3.TileSpacing = 'compact';
t3.Padding = 'compact';
t3.Layout.Tile = 3;
nexttile(t3);
plot(hours,Y_3d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y3_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU3level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 max(SU3level)]));
ylabel('Water Depth (m)','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('$Y^3_X(t)$ Peak','interpreter','latex');
xlim([start_time_1 end_time_1]);
ylim([0,inf]);
nexttile(t3);
plot(hours,Y_3d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,Y3_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,SU3level,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 max(SU3level)]));
xlabel('Time(hh:mm)','interpreter','latex')
set(gca,'YAxisLocation','right')
title('$Y^3_X(t)$ Steady State','interpreter','latex');
xlim([start_time_2 end_time_2]);
ylim([0,inf]);

t4 = tiledlayout(T,1,2);
t4.TileSpacing = 'compact';
t4.Padding = 'compact';
t4.Layout.Tile = 4;
nexttile(t4);
plot(hours,YI_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,YI_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,WWTPlevel,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.5 1 max(WWTPlevel) max(YI_n)]));
xlabel('Time(hh:mm)','interpreter','latex')
title('$Y^I_X(t)$ Peak','interpreter','latex');
xlim([start_time_1 end_time_1]);
ylim([0,inf]);
nexttile(t4);
plot(hours,YI_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,YI_linear,'color',"#FF0000",'LineStyle',':');
plot(hours,WWTPlevel,'color',"#77AC30");
grid on;
ytickformat('%.2f');
yticks(sort([0 0.5 1 max(WWTPlevel) max(YI_n)]));
xlabel('Time(hh:mm)','interpreter','latex')
set(gca,'YAxisLocation','right')
title('$Y^I_X(t)$ Steady State','interpreter','latex');
xlim([start_time_2 end_time_2]);
ylim([0,inf]);

% nexttile;
% plot(hours,Y_2d_n,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,Y2_linear,'color',"#FF0000",'LineStyle',':');
% plot(hours,SU2level,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% legend('Nonlinear Feedback','Linear Feedback','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^2_X(t)$','interpreter','latex');
% xlim([start_time end_time]);
% ylim([0,inf]);
% 
% nexttile;
% plot(hours,Y_3d_n,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,Y3_linear,'color',"#FF0000",'LineStyle',':');
% plot(hours,SU3level,'color',"#77AC30");
% % plot(1:1:N, J3_1inflow);
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Nonlinear IDZ Model','Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^3_X(t)$','interpreter','latex');
% xlim([start_time end_time]);
% ylim([0,inf]);
% % % 
% nexttile;
% plot(hours,YI_n,'color',"#0072BD",'LineStyle','-.');
% hold on;
% plot(hours,YI_linear,'color',"#FF0000",'LineStyle',':');
% plot(hours,WWTPlevel,'color',"#77AC30");
% grid on;
% ylabel('Water Depth (m)','interpreter','latex');
% xlabel('Time(hh:mm)','interpreter','latex')
% % legend('Linear IDZ Model','PCSWMM Simulation','interpreter','latex','Location','northeast');
% title('Downstream Level $Y^I_X(t)$','interpreter','latex');
% xlim([start_time end_time]);
% ylim([0,inf]);
 


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




