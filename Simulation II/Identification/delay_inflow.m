%%% This function takes in the inflows + 2 cell array and its corresponding
%%% equivalent conduit, then it shifts the first length(p2k) inflows by the
%%% delays provided by the conduits.

function output = delay_inflow(inflow,ds_delay)
inflow = makeMinus(inflow);
output = @(t) inflow(t - ds_delay);
end