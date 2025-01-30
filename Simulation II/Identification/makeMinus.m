%%% Given a 1*N vector that represents some function f(t) for
%%% 0<t<time_step*N. We return an output function handle f(t) for
%%% -time_step*N<t<time_step*N, where the negative time values duplicate
%%% the value at t=0.

%%% A problem with this is that there is an index shift by 1. So we augment
%%% the final vector by 1 towards the right, where the value duplicate its
%%% previous value.

function output = makeMinus(input)
N = length(input);

minus_part = input(1)*ones(1,N-1);
complete_part = [minus_part,input,input(end)];
output = @(t) complete_part(t + N);
end