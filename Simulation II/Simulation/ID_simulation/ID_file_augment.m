% n is number of real states
function Depths = ID_file_augment(sys_data,simu_op,delayed_rainfall,u,n)
A = sys_data{1};
B = sys_data{2};
E = sys_data{3};
M = sys_data{4};
time_step = simu_op{1};
T = simu_op{2};
r = delayed_rainfall;
N = size(A,1);

% Take u(t) \in m and transform to u(t) \in m(d_N+1)
d_N = (size(A,1) - size(M,1))/n - 1;
u = @(t) repmat(u(t),[d_N+1,1]);



%% Start simulation
x0 = zeros(N,1);
u0 = u(0);

x = nan(N,T);
x(:,1) = A*x0 + B*u0 + E*r(1);
% w(:,1) = x(n+1:end,1);

for t = 1:1:T-1
    x(:,t+1) = A*x(:,t)+B*u(t)+E*r(t+1);
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

end