function output = delay_inflow_interceptor(inflows,equivc,conduit,time_step)
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


%%% Get ni's
for j = 1:1:length(equivc)
    equivn{j} = length(equivc{j}.p2k);
end
delay = [];
for i = 1:1:length(equivn)
    for j = 1:1:equivn{i}+2
        delay = [delay, taud(i)];
    end
end

% Shift inflows
for i = 1:1:length(delay)
    output{i} = @(t) inflows{i}(t - delay(i));
end
output{length(delay)+1} = inflows{length(delay)+1};

end