%%% This function takes in the inflows cell array and its corresponding
%%% equivalent conduit, then it shifts the inflows by the
%%% delays provided by the conduits.(The downstream delays)

%%% The delay_inflow function returns function handles, this one returns
%%% vectors with elements before delay set to 0.

function output = delay_inflow_ds(inflows,conduit,time_step)
n = length(conduit.p2k);
% Obtain delays
yd = [];
for i = 1:1:n
    yd = [yd, conduit.p2k{i}];
end
yd = [yd, conduit.p2n];
yd_ds = c2d(yd,time_step);
temp = ss(yd_ds);
taud = temp.InputDelay;
taud = taud(1:end-1); % The last element is zero, so remove it.


% Shift inflows
N = length(inflows{1});
for i = 1:1:n
    temp = nan(1,N);
    temp(1:taud(i)) = 0;
    temp(taud(i)+1:end) = inflows{i}(1:length(taud(i)+1:end));
    output{i} = temp;
end