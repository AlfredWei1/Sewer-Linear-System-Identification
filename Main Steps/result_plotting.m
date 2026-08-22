function result_plotting(time,time_step,N,Y_1d_n,Y_2d_n,Y_3d_n,YI_n)
% Read reference simulation data
load('hurricane_dw.mat');

% Set default settings
hours = seconds(time);
hours.Format = 'h';
set(0, 'DefaultLineLineWidth', 2.5);
set(0,'DefaultAxesFontName','Times')
set(0,'DefaultAxesFontSize',12)
pcswwm_color = [0.8500, 0.3250, 0.0980];
pcswmm_width = 4;
legend_fontsize = 25;

% Initialize Figure
figure;
T = tiledlayout(2,2);
T.TileSpacing = 'compact';
T.Padding = 'compact';
sgtitle(' ','interpreter','latex','fontSize',25);
set(gcf, 'Position',  [100, -200, 1300, 850])
hours = time2num(hours);
set(0, 'defaultAxesFontSize', 23, 'DefaultAxesLabelFontSize', 1.0);
title_font_size = 30;
set(0, 'DefaultLineLineWidth', 4);

% Plot the depth at C1 Downstream
t1 = tiledlayout(T,1,1);
t1.TileSpacing = 'compact';
t1.Padding = 'compact';
t1.Layout.Tile = 1;
nexttile(t1);
plot(hours,Y_1d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,SU1level,'color',pcswwm_color,'LineWidth',pcswmm_width);
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(Y_1d_n)]));
ylabel('Depth (m)','interpreter','latex','fontSize',legend_fontsize);
title('$Y^1_d$','interpreter','latex','fontSize',title_font_size);
xticks([0 8 16 24 32 40 48]);
ylim([0,inf]);

% Plot the depth at C2 Downstream
t2 = tiledlayout(T,1,1);
t2.TileSpacing = 'compact';
t2.Padding = 'compact';
t2.Layout.Tile = 2;
nexttile(t2);
plot(hours,Y_2d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,SU2level,'color',pcswwm_color,'LineWidth',pcswmm_width);
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 0.6 max(SU2level) max(Y_2d_n)]));
title('$Y^2_d$','interpreter','latex','fontSize',title_font_size);
xticks([0 8 16 24 32 40 48]);
ylim([0,inf]);
h = legend('IDZ-based Nonlinear Model','PCSWMM','interpreter','latex','Orientation', 'Horizontal','Location','northeast','fontSize',legend_fontsize);

% Plot the depth at C3 Downstream
t3 = tiledlayout(T,1,1);
t3.TileSpacing = 'compact';
t3.Padding = 'compact';
t3.Layout.Tile = 3;
nexttile(t3);
plot(hours,Y_3d_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,SU3level,'color',pcswwm_color,'LineWidth',pcswmm_width);
grid on;
ytickformat('%.2f');
yticks(sort([0 0.2 0.4 max(SU3level)]));
ylabel('Depth (m)','interpreter','latex','fontSize',legend_fontsize);
xlabel('Time (h)','interpreter','latex','fontSize',legend_fontsize)
title('$Y^3_d$','interpreter','latex','fontSize',title_font_size);
xticks([0 8 16 24 32 40 48]);
ylim([0,inf]);

% Plot the depth at C4 Downstream
t4 = tiledlayout(T,1,1);
t4.TileSpacing = 'compact';
t4.Padding = 'compact';
t4.Layout.Tile = 4;
nexttile(t4);
plot(hours,YI_n,'color',"#0072BD",'LineStyle','-.');
hold on;
plot(hours,WWTPlevel,'color',pcswwm_color,'LineWidth',pcswmm_width);
grid on;
ytickformat('%.2f');
yticks(sort([0 0.5 1 max(WWTPlevel) max(YI_n)]));
xlabel('Time (h)','interpreter','latex','fontSize',legend_fontsize)
title('$Y^I_d$','interpreter','latex','fontSize',title_font_size);
xticks([0 8 16 24 32 40 48]);
ylim([0,inf]);