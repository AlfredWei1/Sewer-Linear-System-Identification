%%% This function takes in the inflows cell array and its corresponding
%%% equivalent conduit, then it shifts the inflows by the
%%% delays provided by the conduits.(The downstream delays)

%%% The delay_inflow function returns function handles, this one returns
%%% vectors with elements before delay set to 0.

function output = delay_rainfall_constant(rainfall,discrete_delay)
% Rainfall is a cell array of function handles
N = length(rainfall);
for i = 1:1:N
    output{i} = @(t) rainfall{i}(t - discrete_delay);
end
end