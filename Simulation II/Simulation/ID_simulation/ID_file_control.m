% n is number of real states
function [Depths,Controls] = ID_file_augment(sys_data,simu_op,delayed_rainfall,control_data,n)
A = sys_data{1};
B = sys_data{2};
E = sys_data{3};
M = sys_data{4};
time_step = simu_op{1};
T = simu_op{2};
r = delayed_rainfall;
N = size(A,1);

K0 = control_data{1};
kappa0 = control_data{2};
K = control_data{3};
kappa = control_data{4};


%% Start simulation
x0 = zeros(N,1);
u0 = bound(K0*x0 + kappa0);

x = nan(N,T);
u = nan(size(B,2),T);
x(:,1) = A*x0 + B*u0 + E*r(1);
u(:,1) = bound(K{1}*x(:,1) + kappa{1});
% w(:,1) = x(n+1:end,1);

for t = 1:1:T-1
%     u(:,t+1) = bound(K{t}*x(:,t) + kappa{t});
    u(:,t+1) = bound(K{t}*x(:,t));
%     x(:,t+1) = A*x(:,t)+B*(bound(K{t}*x(:,t) + kappa{t}))+E*r(t+1);
    x(:,t+1) = A*x(:,t)+B*(bound(K{t}*x(:,t)))+E*r(t+1);
%     w(:,t+1) = x(n+1:end,t+1);
end

% w_new = w;
% load('old_w.mat');
% tempw = w;
% w = nan(length(E),T);
% for t = 1:1:T
%     w_old(:,t) = tempw(t); %Not problem about w, but about other parts?
% end

Depths = x(1:n,:);
Controls = u(1:4,:);

end