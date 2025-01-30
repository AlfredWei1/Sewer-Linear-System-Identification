%%% This function takes rainfall data and inflows data, then recompile the
%%% culmulative rainfall data to the differential one.

function plot_rainfall_inflow(rainfall,time_step,N,inflows)

% If N is not multiple of 3600/time_step, we extend it
if ~isinteger(N/(3600/time_step))
    inte = ceil(N/(3600/time_step));
    new_N = inte*(3600/time_step);
    for i = 1:1:length(inflows)
        inflows{i} = [inflows{i},inflows{i}(end)*ones(1,new_N-N)];
    end
    rainfall = [rainfall,rainfall(end)*ones(1,new_N-N)];
    N = new_N;
end

time = 0:time_step:N*time_step-time_step;
hours = seconds(time);
hours.Format = 'hh:mm';

% Read Data
N_inflows = length(inflows);
if length(inflows) == 0
    number1 = 1;
    number2 = 1;
else
    number1 = ceil(N_inflows/3);
    number2 = 4;
end

% average_rainfall = nan(1,N/(3600/time_step));
% 
% counter = 1;
% for i=1:720:N
%     if counter == 1
%         average_rainfall(counter) = rainfall(720-1) - 0;
%     else
%         average_rainfall(counter) = rainfall(i+720-1) - rainfall(i-1);
%     end
%     if counter == N/(3600/time_step)
%         break;
%     end
%     counter = counter + 1;
% end
% 
% rainfall = zeros(1,N);
% for i = 1:1:N
%     rainfall(i) = average_rainfall(ceil(i/(3600/time_step)));
% end

rainfall_timestep = 60;

rainfall_diff = [];
counter = 1;
for i = 1:rainfall_timestep:N-rainfall_timestep
    rainfall_diff = [rainfall_diff,rainfall(i+60)-rainfall(i)];
end
rainfall_diff = [rainfall_diff,rainfall_diff(end)];
rainfall_diff = repelem(rainfall_diff,rainfall_timestep);
rainfall = rainfall_diff;

%% Start Plotting here
N_inflows = length(inflows);

figure;
my_figure_rainfall = tiledlayout(2,2);
set(gcf, 'Position',  [100, 100, 1000, 400])

nexttile;
plot(hours,rainfall,'color',"#0072BD");
title('Rainfall','interpreter','latex');
xlabel('Time(hh:mm)','interpreter','latex');
ylabel("Rainfall (mm/hr)",'interpreter','latex');
grid on;

if length(inflows) == 0
else
    for i = 1:1:N_inflows
        nexttile;
        plot(hours,inflows{i},'color',"#0072BD");
        title_name = "Lateral Inflow at Upstream of Conduit" + " " + num2str(i);
        title(title_name,'interpreter','latex');
        xlabel('Time(hh:mm)','interpreter','latex');
        ylabel("Inflow (m$^3$/s)",'interpreter','latex');
        grid on;
    end
end
end