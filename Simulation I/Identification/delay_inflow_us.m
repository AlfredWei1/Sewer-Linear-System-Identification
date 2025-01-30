%%% This function takes in the inflows cell array and its corresponding
%%% equivalent conduit, then it shifts the inflows by the
%%% delays provided by the conduits.(The upstream delays)

%%% The delay_inflow function returns function handles, this one returns
%%% vectors with elements before delay set to 0.

function output = delay_inflow_us(inflows,conduit,time_step)
n = length(conduit.p1k);
% Obtain delays
yu = [];
for i = 1:1:n
    yu = [yu, conduit.p1k{i}];
end
yu = [yu, conduit.p1n];
yu_ds = c2d(yu,time_step);
temp = ss(yu_ds);
taud = temp.InputDelay;
taud = taud(1:end-1); % The last element is downstream delay, so remove it.


% Shift inflows
N = length(inflows{1});
for i = 1:1:n
    if i == 1
        output{i} = inflows{i};
    else
        temp = nan(1,N);
        temp(1:taud(i)) = 0;
        temp(taud(i)+1:end) = inflows{i}(1:length(taud(i)+1:end));
        output{i} = temp;
    end
end