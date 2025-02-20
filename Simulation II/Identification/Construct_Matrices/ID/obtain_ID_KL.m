function [equiv_K,equiv_L,equiv_K_CSO] = obtain_ID_KL(equiv_conduits,interceptor,YX,orifice)
%% Import Parameters
CSO_counter = 1;
OR_counter = 1;
for i = 1:1:length(orifice)
    if rem(i,2) == 0 % if i is even, it is CSO orifice
        Cd = 0.65;
        A0 = orifice{i}(2);
        g = 9.81;
        Yfull = orifice{i}(4);
        Z0 = orifice{i}(5);
        CSO{CSO_counter} = [Cd,A0,g,Yfull,Z0];
        CSO_counter = CSO_counter + 1;
    elseif rem(i,2) == 1 % if i is odd, it is OR orifice
        Cd = 0.65;
        A0 = orifice{i}(2);
        g = 9.81;
        Yfull = orifice{i}(4);
        Z0 = orifice{i}(5);
        OR{OR_counter} = [Cd,A0,g,Yfull,Z0];
        OR_counter = OR_counter + 1;
    end
end

%% Compute Orifice Gains
h = 0.01;
for i = 1:1:length(CSO)
    CSO_gain{i} = (torri(YX{i}+h,CSO{i}) - torri(YX{i},CSO{i}))/h;
end
for i = 1:1:length(OR)
    OR_gain{i} = (torri(YX{i}+h,OR{i}) - torri(YX{i},OR{i}))/h;
    L{i} = (torri_full(YX{i},0.99+h,OR{i}) - torri_full(YX{i},0.99,OR{i}))/h;
end

equiv_K = cell2mat(OR_gain);
equiv_K = equiv_K(1:end-1);
equiv_L = cell2mat(L);
equiv_L = equiv_L(1:end-1);
equiv_K_CSO = cell2mat(CSO_gain);

for i = 1:1:length(YX)-1
    n{i} = length(equiv_conduits{i}.p2k);
end

%% Compute Matrices
for i = 1:1:length(YX)-1
    [Asup{i},Bsup{i},Esup{i}] = equivCond_matrix(equiv_conduits{i},CSO_gain{i},OR_gain{i},L{i},0);
end

index = length(YX);
[AI,BI,EI] = interceptor_ID_matrix(interceptor,OR_gain{index},L{index},equiv_K,equiv_L,n);

N = length(YX)-1;
A0 = [];
B0 = [];
for i = 1:1:N
    A0 = blkdiag(A0,Asup{i});
    B0 = blkdiag(B0,Bsup{i});
end
A0 = blkdiag(A0,AI{N+1});
B0 = blkdiag(B0,BI{N+1});

for i = 1:1:N
    up_matrix = zeros(N,N+1);
    left_matrix = zeros(1,i-1);
    right_matrix = zeros(1,N+1-length(left_matrix) - 1);
    A{i} = [up_matrix;[left_matrix,AI{i},right_matrix]];
    B{i} = [up_matrix;[left_matrix,BI{i},right_matrix]];
end

E = [];
for i = 1:1:N
    E = blkdiag(E,Esup{i});
end
E = blkdiag(E,EI);

%% Compute Delays
taud = cell2mat(interceptor.taudk);
xdelay = [0,taud];
udelay = xdelay;

%% Compute Exoflow constants
CSO_counter = 1;
OR_counter = 1;
for i = 1:1:2*N
    if rem(i,2) == 0 % if i is even, compute exoflow for CSO
        op_depth = YX{CSO_counter};
        CSO_flow = torri(op_depth,CSO{CSO_counter});
        exoflow{i} = CSO_flow - CSO_gain{CSO_counter}*op_depth;
        CSO_counter = CSO_counter + 1;
    elseif rem(i,2) == 1 % if i is odd, compute exoflow for OR
        op_depth = YX{OR_counter};
        OR_flow = torri(op_depth,OR{OR_counter});
        exoflow{i} = OR_flow - OR_gain{OR_counter}*op_depth;
        OR_counter = OR_counter + 1;
    end
end

op_depth = YX{end};
OR_flow = torri(op_depth,OR{N+1});
exoflow{2*N+1} = OR_flow - OR_gain{N+1}*op_depth;
end

%% The nonlinear Torricelli's Law

function Q = torri_full(Y,W,data)

% Import Orifice Data
Cd = data(1);
A0 = data(2);
g = data(3);
Yfull = data(4);
Z0 = data(5);

% Adjust Area Opening according to W
A0 = W*A0;

% Compute Outflow
if Y <= Z0
        Q = 0;
    elseif Y > Z0 && Y < Z0 + (3/4)*W*Yfull
        CwL = sqrt(32/27)*(Cd*A0*sqrt(g))/(W*Yfull);
        Q = CwL*(Y-Z0)^(1.5);
    else
        He = Y-(Z0 + (W*Yfull)/2);
        Q = Cd*A0*sqrt(2*g*He);
end

end

function Q = torri(Y,data)

% Import Orifice Data
Cd = data(1);
A0 = data(2);
g = data(3);
Yfull = data(4);
Z0 = data(5);

constant = sqrt(32/27);
boundary = 0.25*(3*Yfull + 4*Z0);

% constant = 1;
% boundary = Yfull + Z0;

% Compute Outflow
if Y <= Z0
        Q = 0;
    elseif Y > Z0 && Y < boundary
        CwL = (Cd*A0*sqrt(g))/(Yfull);
        CwL = constant*CwL;
        Q = CwL*(Y-Z0)^(1.5);
    else
        He = Y-(Z0 + Yfull/2);
        Q = Cd*A0*sqrt(2*g*He);
end
end