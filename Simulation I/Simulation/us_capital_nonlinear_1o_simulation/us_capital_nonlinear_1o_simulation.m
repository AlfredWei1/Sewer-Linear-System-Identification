%%% This function takes in: inflows, inflow_prop, model_link, and orifice data
%%% and outputs: the downstream water depth.

%%% The name "capital" means: it uses the equivalent initialization.
%%% 'ds' means the output is downstream water depth
%%% 'nonlinear' means the feedback function is nonlinear
%%% '1o' means there is only a side orifice

%%% 'inflow_prop' determines whether the corresponding inflow takes
%%% lower-letter (i.e., does it come in the middle or at the top). 0 means
%%% inflow at interconnection, 1 means inflow at most upstreams.

%%% 'Q0' is an array of operating flows at each conduit.
%%% 'YX' is the operating depth of the most downstream node.

%%% Aside from outputting the downstream depth, this function also returns
%%% the flows out of the two orifices.

function Y_upstream = us_capital_nonlinear_1o_simulation(inflows,C,OR,ds_outflow,time_step,N)
n = length(inflows);

% Obtain A,B,C,D matrices
yu = [];
for i = 1:1:n
    yu = [yu, C.p1k{i}];
end
yu = [yu, C.p1n];
yu_ds = c2d(yu,time_step);
temp = ss(yu_ds);
A = temp.A;
B = temp.B;
C = temp.C;
D = temp.D;
taud = temp.InputDelay;
ds_delay = taud(end);

% Set inflows, note the inflows are function handles
time = 0:time_step:N*time_step-time_step;
simu_input = [time'];
for i = 1:1:length(inflows)
    simu_input = [simu_input, inflows{i}'];
end

ds_outflow = [time',ds_outflow];

save('Simulation/us_capital_nonlinear_1o_simulation/us_capital_nonlinear_1o_simulation_data.mat');

% Simulate System
simu_file = 'us_capital_nonlinear_1o_simulation_simu';
simIn = Simulink.SimulationInput(simu_file);
simIn = loadVariablesFromMATFile(simIn,"us_capital_nonlinear_1o_simulation_data.mat");
warning('off');
out = sim(simIn);
clc;

Y_upstream = out.YX.data(1:end-1);

end