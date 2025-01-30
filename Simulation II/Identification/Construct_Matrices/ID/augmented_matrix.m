%%% This function assumes ID Model x_{t+1} = \sum A_i x(t-di) + \sum B_i
%%% u(t-di) + Ew_t, w_{t+1} = Mw(t) + r(t). We aim to construct X_{t+1} =
%%% bold{A}X_t + bold{B}U_t + bold{E}r(t) as an augmented matrix with
%%% delayed states and w(t) dynamics embedded in X.

%%% Note inputs should be continuous-time versions of matrices

%%% The original x is the first size(A0,1) elements of X

function [A,B,E] = augmented_matrix(A0,B0,A,B,E,delays,M,time_step)
% Before starting, we discretize the quantities
N = length(A0)-1;
A0 = time_step*A0 + eye(N+1,N+1);
B0 = time_step*B0;
for i = 1:1:length(A)
    A{i} = time_step*A{i};
    B{i} = time_step*B{i};
end
E = time_step*E;
M = time_step*M + eye(length(M));

% Discretize delays
for i = 1:1:length(delays)
    delays(i) = ceil(delays(i)/time_step);
end
delays = delays(2:end);

% As a first step, we transform system into \sum_{i=0}^{d_N} A_i x(t-i)
d_N = max(delays);
n = size(A0,1);
m = size(B0,2);
N_w = size(E,2);
if d_N == 0 % If there is no delay, we simply augment M onto A0,B0
    A = [A0,E;zeros(size(M,1),size(A0,2)),M];
    B = [B0;zeros(size(A,1)-size(B0,1),size(B0,2))];
    E = [zeros(n*(d_N+1),N_w);eye(N_w,N_w)];
    return;
end % This if is just for testing purposes. It is impossible that time delays are 0, else the interceptor would have no inflow.

counter = 1;
for i = 1:1:d_N
    if ismember(i,delays)
        A_temp{i} = A{counter};
        B_temp{i} = B{counter};
        counter = counter + 1 ;
    else
        A_temp{i} = zeros(n,n);
        B_temp{i} = zeros(n,m);
    end
end
A = A_temp;
B = B_temp;

%As a second step, use remark 2 from Linear quadratic Gaussian control for linear
%time-delay systems. Note A_p is of dimension n(d_N+1)*n(d_N+1), B_p is
%of dimension n(d_N+1)*m(d_N+1), and A_tilde is of dimension
%n*(d_N+1)*n
A_p = A0;
B_p = B0;
for i = 1:1:d_N %Iterate columns of A_p
    A_p = [A_p,A{i}];
end
for i = 1:1:d_N %Iterate rows of A_p
    remaining = n*(d_N+1)-n-(i-1)*n;
    matrix_temp = [zeros(n,n*(i-1)),eye(n,n),zeros(n,remaining)];
    A_p = [A_p;matrix_temp];
end
for i = 1:1:d_N %Iterate columns of B_p
    B_p = [B_p,B{i}];
end
B_p = [B_p;zeros(n*d_N,m*(d_N+1))]; %Fill remaining of B_p

A_tilde = eye(n,n);
A_tilde = [A_tilde; zeros(n*(d_N),n)];

%As a third step, form A,B,E by augmenting matrix M into the dynamics
A = [A_p,A_tilde*E;zeros(size(M,1),size(A_p,2)),M];
B = [B_p;zeros(size(A,1)-size(B_p,1),size(B_p,2))];
E = [zeros(n*(d_N+1),N_w);eye(N_w,N_w)];
end