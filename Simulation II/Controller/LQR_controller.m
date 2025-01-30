%%% This function computes the LQR controller u_t(Y_t) = K_t Y_t + kappa_t

%%% Assume our system has horizon t = 0,...,T

%%% A,B,E,Q,R are constant matrices (augmented)
%%% wbar is cell array of length T is recording mean prediction of rainfall,
%%% Wbar is the augmented variance matrix having dimension of N_w * N_w
%%% w0 is the mean prediction of rainfall at time 0

function [K0,kappa0,K,kappa]=LQR_controller(A,B,E,Q,R,wbar,w0,Wbar)
% Note all matrices defined below are defined for t = 1,...,T. t = 0 case
% will be separate.
T = length(wbar);
P = cell(1,T);
q = cell(1,T);
r = cell(1,T);
K = cell(1,T-1);
kappa = cell(1,T-1);

n = size(A,1);
m = size(B,2);
N_w = size(E,2);

P{T} = zeros(n,n);
q{T} = zeros(n,1);
r{T} = 0;

for t = T-1:-1:1
    K{t} = -inv(R + B'*P{t+1}*B)*B'*P{t+1}*A;
    kappa{t} = -inv(R + B'*P{t+1}*B)*B'*P{t+1}*E*wbar{t} - 0.5*inv(R + B'*P{t+1}*B)*B'*q{t+1};

    P{t} = K{t}'*R*K{t} + K{t}'*B'*P{t+1}*B*K{t} + A'*P{t+1}*B*K{t} + Q + A'*P{t+1}*A;
    q{t} = (2*kappa{t}'*R*K{t} + 2*kappa{t}'*B'*P{t+1}*B*K{t} + 2*kappa{t}'*B'*P{t+1}*A + ...
        2*wbar{t}'*E'*P{t+1}*B*K{t} + q{t+1}'*B*K{t} + q{t+1}'*A + 2*wbar{t}'*E'*P{t+1}*A)';
    r{t} = kappa{t}'*R*kappa{t} + kappa{t}'*B'*P{t+1}*B*kappa{t} + 2*wbar{t}'*E'*P{t+1}*B*kappa{t}+...
        q{t+1}'*B*kappa{t} + q{t+1}'*E*wbar{t} + trace(E'*P{t+1}*E*Wbar) + r{t+1};
end

t = 0;
K0 = -inv(R + B'*P{t+1}*B)*B'*P{t+1}*A;
kappa0 = -inv(R + B'*P{t+1}*B)*B'*P{t+1}*E*w0 - 0.5*inv(R + B'*P{t+1}*B)*B'*q{t+1};

% P0 = K{t}'*R*K{t} + K{t}'*B'*P{t+1}*B*K{t} + A'*P{t+1}*B*K{t} + Q + A'*P{t+1}*A;
% q0 = (2*kappa{t}'*R*K{t} + 2*kappa{t}'*B'*P{t+1}*B*K{t} + 2*kappa{t}'*B'*P{t+1}*A + ...
%         2*w0'*E'*P{t+1}*B*K{t} + q{t+1}'*B*K{t} + q_{t+1}'*A + 2*w0'*E'*P{t+1}*A)';
% r0 = kappa{t}'*R*kappa{t} + kappa{t}'*B'*P{t+1}*B*kappa{t} + 2*w0'*E'*P{t+1}*B*kappa{t}+...
%         q{t+1}'*B*kappa{t} + q{t+1}'*E*w0 + trace(E'*P{t+1}*E*Wbar) + r{t+1};

end