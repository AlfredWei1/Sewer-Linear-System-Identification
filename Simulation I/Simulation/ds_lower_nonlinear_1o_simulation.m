%%% This function takes in: inflows, inflow_prop, model_link, and orifice data
%%% and outputs: the downstream water depth.

%%% The name "lower" means: it uses the original initializaiton.
%%% 'ds' means the output is downstream water depth
%%% 'nonlinear' means the feedback function is nonlinear
%%% '1o' means there is only a side orifice

%%% 'inflow_prop' determines whether the corresponding inflow takes
%%% lower-letter (i.e., does it come in the middle or at the top). 0 means
%%% inflow at interconnection, 1 means inflow at most upstreams.

%%% 'Q0' is an array of operating flows at each conduit.
%%% 'YX' is the operating depth of the most downstream node.

function Y_downstream = ds_lower_nonlinear_1o_simulation(inflows,inflow_prop,C,data,Q0,YX,time_step,N)
n = length(inflows);

% Import orifice data
Cd = data(1);
A0 = data(2);
g = data(3);
Yfull = data(4);
Z0 = data(5);

% Obtain system
yd = [];
for i = 1:1:n
    yd = [yd, C.p2k{i}];
end
yd = [yd, C.p2n];
yd_ds = c2d(yd,time_step);
temp = ss(yd_ds);
A = temp.A;
B = temp.B;
C = temp.C;
D = temp.D;
taud = temp.InputDelay;
[taud_ordered,order_index] = sort(taud);

% Initialize variables
for i = 1:1:n
    Q_k{i} = inflows{i};
end
for i = 1:1:n
    if inflow_prop(i) == 0 % I.e., such inflow is an inflow at interconnection.
        q_k{i} = Q_k{i};
    elseif inflow_prop(i) == 1 % I.e., such inflow is an inflow at the most upstreams
        q_k{i} = Q_k{i} - Q0{i};
    else
        error('inflow_prop can only be either 0 or 1.');
    end
end

y_X = nan(1,N);
Y_X = nan(1,N);
Q_X = nan(1,N);
q_X = nan(1,N);
x = nan(1,N);
flow = nan(n+1,N);

% Initialize the system at time 1
Q_X(1) = 0;
q_X(1) = Q_X(1) - Q0{end};

Y_X(1) = 0;
y_X(1) = Y_X(1) - YX{end};

temp = cell(1,n+1);
for i = 1:1:n
    if inflow_prop(i) == 0
        temp{i} = 0;
    elseif inflow_prop(i) == 1
        temp{i} = 0 - Q0{i};
    else
        error('inflow_prop can only be either 0 or 1.');
    end
end
temp{n+1} = q_X(1);
temp = cell2mat(temp);
flow(:,1) = temp;
x(1) = inv(C)*(y_X(1)-D*flow(:,1));

% Simulate system after time 1
for t = 2:1:N
    
    % Compute gate outflow
    if Y_X(t-1) <= Z0
        Q_X(t) = 0;
    elseif Y_X(t-1) > Z0 && Y_X(t-1) < Z0 + Yfull
        CwL = (Cd*A0*sqrt(g))/(Yfull);
        Q_X(t) = CwL*(Y_X(t-1)-Z0)^(1.5);
    else
        He = Y_X(t-1)-(Z0 + Yfull/2);
        Q_X(t) = Cd*A0*sqrt(2*g*He);
    end
    q_X(t) = Q_X(t) - Q0{end};
    
    % Determine flow by incorporating delay
    
    my_case = my_t_case(taud_ordered,t);
    t_array = 1:1:my_case;
    choose = order_index(t_array);

    temp = cell(1,n+1);
    for i = 1:1:n
        if ismember(i,choose)
            inflow = q_k{i};
            temp{i} = inflow(t - taud(i));
        else
            if inflow_prop(i) == 1  
                temp{i} = 0 - Q0{i};
            else
                temp{i} = 0;
            end
        end
    end
    temp{n+1} = q_X(t);
    temp = cell2mat(temp);
    flow(:,t) = temp;
   

    % Update state and output
    x(t) = A*x(t-1)+B*flow(:,t-1);
    y_X(t) = C*x(t) + D*flow(:,t);
    Y_X(t) = y_X(t) + YX{5};
end

Y_downstream = Y_X;
end