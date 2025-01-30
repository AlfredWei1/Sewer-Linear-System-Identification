%%% This function reads "control_matrices.mat" to know the controller. It
%%% take in depths at the four nodes for current time and previous 10
%%% times. It returns a 1*4 vector consisting of the settings at the
%%% orifices.

%%% It also reads current time t to know which controller to apply, because
%%% our control is time-variant.

function setting = control_execution(depth,t)
t = double(t);
load("control_matrices.mat");
x = [];
for i = 1:1:length(depth) % This number should be 11
    x = [x;double(cell2mat(depth{i})')];
end
if t == 0
    setting = K0*x + kappa0;
else
    setting = K{t}*x + kappa{t};
end
setting = bound(setting) + ones(4,1);
end