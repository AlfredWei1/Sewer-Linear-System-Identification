%%% This function takes in the ABECDF matrices for the equivalent conduit i
%%% and simulate the system with the given inflows. Moreover, the delay is
%%% given by the conduit variable (should be a model_link).

%%% Note the ABECDF matrices should be in discrete-time.

%%% Q0 and YX are the operating points of the most downstream conduit in
%%% the equivalent conduit.

function [Y_downstream,x_output] = ds_capital_linear_2o_simulation(A,B,E,C,D,F,K_constant,inflows,conduit,time_step,Q0,YX,N)
n = length(inflows) - 2;
% Obtain system
yd = [];
for i = 1:1:n
    yd = [yd, conduit.p2k{i}];
end
yd = [yd, conduit.p2n];
yd_ds = c2d(yd,time_step);
temp = ss(yd_ds);
taud = temp.InputDelay;

%% Start Simulation

% Initialize variables
Y_X = nan(1,N);
x = nan(1,N);
our_inflow = nan(n+2,N);

% Initialize the system at time 1
Y_X(1) = 0;

temp = cell(1,n+2);
for i = 1:1:n
        temp{i} = inflows{i}(0);
end
temp{n+1} = inflows{n+1}(0);
temp{n+2} = inflows{n+2}(0);
temp = cell2mat(temp);
our_inflow(:,1) = temp;
x(1) = 0;

% Simulate system after time 1
for t = 2:1:N
    temp = cell(1,n+2);
    for i = 1:1:n
        temp{i} = inflows{i}(t); % We note the flows are already delayed
    end
    temp{n+1} = inflows{n+1}(1);
    temp{n+2} = inflows{n+2}(1);
    temp = cell2mat(temp);
    our_inflow(:,t) = temp;
   

    % Update state and output
    x(t) = A*x(t-1)+E*our_inflow(:,t-1);
    Y_X(t) = C*x(t) + F*our_inflow(:,t);
end

Y_downstream = Y_X;
x_output = x;

end