%%% This function takes in the inflows + 2 cell array and its corresponding
%%% equivalent conduit, then it shifts the first length(p2k) inflows by the
%%% delays provided by the conduits.

function output = delay_inflow(inflows,conduit,time_step)
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
for i = 1:1:n
    output{i} = @(t) inflows{i}(t - taud(i));
end
output{n+1} = @(t) inflows{n+1}(t - taud(i));

if length(inflows) >= n+2
    output{n+2} = @(t) inflows{n+2}(t - taud(i));
end
end