function output = plot_result(data_input_LQR,string_input_LQR,data_input_RB,string_input_RB)
for i = 1:1:length(data_input_LQR)
    data_input_LQR{i} = cell2mat(data_input_LQR{i});
    eval(string_input_LQR{i} + "= data_input_LQR{i}");
end
for i = 1:1:length(data_input_RB)
    data_input_RB{i} = cell2mat(data_input_RB{i});
    eval(string_input_RB{i} + "_RB= data_input_RB{i}");
end

draw_depths = 1;
show_total_CSO = 1;
draw_floodings = 0;
draw_setting = 0;

N = length(SU1level);
time_step = 300;
time = 0:time_step:N*time_step-time_step;
hours = seconds(time);
hours.Format = 'hh:mm';
set(0, 'DefaultLineLineWidth', 2.5);
set(0,'DefaultAxesFontName','Times');
set(0,'DefaultAxesFontSize',12);

if draw_depths == 1
figure;
T = tiledlayout(2,2);
T.TileSpacing = 'compact';
T.Padding = 'compact';
sgtitle('Water Depths and Orifice Settings','interpreter','latex','fontSize',16);
set(gcf, 'Position',  [100, 100, 1300, 500]);

t1 = tiledlayout(T,1,2);
t1.TileSpacing = 'compact';
t1.Padding = 'compact';
t1.Layout.Tile = 1;
nexttile(t1);
plot(hours,SU1level,'color',"#77AC30");
hold on;
plot(hours,SU1level_RB,'color',"#7E2F8E");
grid on;
ylabel('Depth (m)','interpreter','latex');
title('Downstream Level $Y^1_X(t)$','interpreter','latex');
nexttile(t1);
plot(hours,OR1set,'color',"#77AC30");
hold on;
plot(hours,OR1set_RB,'color',"#7E2F8E");
grid on;
set(gca,'YAxisLocation','right')
title('OR1 Setting','interpreter','latex');

t2 = tiledlayout(T,1,2);
t2.TileSpacing = 'compact';
t2.Padding = 'compact';
t2.Layout.Tile = 2;
nexttile(t2);
plot(hours,SU2level,'color',"#77AC30");
hold on;
plot(hours,SU2level_RB,'color',"#7E2F8E");
grid on;
title('Downstream Level $Y^2_X(t)$','interpreter','latex');
nexttile(t2);
plot(hours,OR2set,'color',"#77AC30");
hold on;
plot(hours,OR2set_RB,'color',"#7E2F8E");
grid on;
set(gca,'YAxisLocation','right')
ylabel('Opening','interpreter','latex');
title('OR2 Setting','interpreter','latex');

h = legend('Stochastic LQR','Rule-based Control','Orientation', 'Horizontal','Location','north');
% set(h,'Position',[0.65 0.95 0.3 0.04]);
% set(h,'Position','north');

t3 = tiledlayout(T,1,2);
t3.TileSpacing = 'compact';
t3.Padding = 'compact';
t3.Layout.Tile = 3;
nexttile(t3);
plot(hours,SU3level,'color',"#77AC30");
hold on;
plot(hours,SU3level_RB,'color',"#7E2F8E");
grid on;
xlabel('Time(hh:mm)','interpreter','latex');
ylabel('Depth (m)','interpreter','latex');
title('Downstream Level $Y^3_X(t)$','interpreter','latex');
nexttile(t3);
plot(hours,OR3set,'color',"#77AC30");
hold on;
plot(hours,OR3set_RB,'color',"#7E2F8E");
grid on;
xlabel('Time(hh:mm)','interpreter','latex');
set(gca,'YAxisLocation','right')
title('OR3 Setting','interpreter','latex');

t4 = tiledlayout(T,1,2);
t4.TileSpacing = 'compact';
t4.Padding = 'compact';
t4.Layout.Tile = 4;
nexttile(t4);
plot(hours,WWTPlevel,'color',"#77AC30");
hold on;
plot(hours,WWTPlevel_RB,'color',"#7E2F8E");
grid on;
xlabel('Time(hh:mm)','interpreter','latex');
title('Downstream Level $Y^I_X(t)$','interpreter','latex');
nexttile(t4);
plot(hours,ORIset,'color',"#77AC30");
hold on;
plot(hours,ORIset_RB,'color',"#7E2F8E");
grid on;
xlabel('Time(hh:mm)','interpreter','latex');
set(gca,'YAxisLocation','right')
ylabel('Opening','interpreter','latex');
title('ORI Setting','interpreter','latex');
end

if show_total_CSO == 1
C1_CSO = sum(CSO1flow)*300;
C2_CSO = sum(CSO2flow)*300;
C3_CSO = sum(CSO3flow)*300;
CSO_LQR = C1_CSO + C2_CSO + C3_CSO;
C1_CSO_RB = sum(CSO1flow_RB)*300;
C2_CSO_RB = sum(CSO2flow_RB)*300;
C3_CSO_RB = sum(CSO3flow_RB)*300;
CSO_RB = C1_CSO_RB + C2_CSO_RB + C3_CSO_RB;
fprintf("Total CSO at CSO1 is " + num2str(C1_CSO) + " under stochastic LQR and " +num2str(C1_CSO_RB) + " under rule-based control.\n")
fprintf("Total CSO at CSO2 is " + num2str(C2_CSO) + " under stochastic LQR and " +num2str(C2_CSO_RB) + " under rule-based control.\n")
fprintf("Total CSO at CSO3 is " + num2str(C3_CSO) + " under stochastic LQR and " +num2str(C3_CSO_RB) + " under rule-based control.\n")
fprintf("Total Volume of CSO under stochastic LQR is " + num2str(CSO_LQR) + " and under rule-based control is " + num2str(CSO_RB) + "\n\n")
end

if draw_floodings == 1
figure;
my_figure_2 = tiledlayout(3,2);
sgtitle('Floodings');
set(gcf, 'Position',  [100, 100, 1200, 500])


nexttile;
plot(hours,SU1flood,'color',"#77AC30");
hold on;
plot(hours,SU1flood_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('SU1Flooding','interpreter','latex');
% xlim([start_time end_time]);
% ylim([0,inf]);

nexttile;
plot(hours,SU2flood,'color',"#77AC30");
hold on;
plot(hours,SU2flood_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
legend('Stochastic LQR','Rule-based Control','interpreter','latex','Location','northeast');
title('SU2Flooding','interpreter','latex');

nexttile;
plot(hours,SU3flood,'color',"#77AC30");
hold on;
plot(hours,SU3flood_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('SU3Flooding','interpreter','latex');
% % 
nexttile;
plot(hours,WWTPflood,'color',"#77AC30");
hold on;
plot(hours,WWTPflood_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('WWTP Flooding','interpreter','latex');

nexttile;
plot(hours,JI3flood,'color',"#77AC30");
hold on;
plot(hours,JI3flood_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('JI3Flooding','interpreter','latex');

nexttile;
plot(hours,flooding,'color',"#77AC30");
hold on;
plot(hours,flooding_RB);
grid on;
ylabel('Flow','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('System Flooding','interpreter','latex');
end

if draw_setting == 1
figure;
my_figure_2 = tiledlayout(2,2);
sgtitle('Setting');
set(gcf, 'Position',  [100, 100, 1200, 500])


nexttile;
plot(hours,OR1set,'color',"#77AC30");
hold on;
plot(hours,OR1set_RB);
grid on;
ylabel('Openning','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('OR1 Setting','interpreter','latex');
% xlim([start_time end_time]);
% ylim([0,inf]);

nexttile;
plot(hours,OR2set,'color',"#77AC30");
hold on;
plot(hours,OR2set_RB);
grid on;
ylabel('Openning','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
legend('Stochastic LQR','Rule-based Control','interpreter','latex','Location','northeast');
title('OR2 Setting','interpreter','latex');

nexttile;
plot(hours,OR3set,'color',"#77AC30");
hold on;
plot(hours,OR3set_RB);
grid on;
ylabel('Openning','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('OR3 Setting','interpreter','latex');
% % 
nexttile;
plot(hours,ORIset,'color',"#77AC30");
hold on;
plot(hours,ORIset_RB);
grid on;
ylabel('Openning','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex')
title('ORI Setting','interpreter','latex');
end

if any(flooding)
    fprintf("The LQR system is flooding. \n\n")
end
if any(flooding_RB)
    fprintf("The Rule-based system is flooding. \n\n")
end
output = 1;
end