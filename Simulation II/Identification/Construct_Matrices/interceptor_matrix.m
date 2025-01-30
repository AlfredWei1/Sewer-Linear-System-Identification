%%% This function takes in the interceptor and the linear gain associated
%%% to the one orifice.
%%% As the outputs, it returns the
%%% A^I,B^I,E^I,C^I,D^I, and F^I matrices. The withzero factor determines
%%% whether we want the zero in our final model or not.

%%% We note these matrices are in continuous-time.

function [A,B,E,C,D,F] = interceptor_matrix(conduit,K,L,equiv,withzero)
Ad = conduit.Ad;
p2X = conduit.p2n_inf;
p2k = conduit.p2k_inf;

if withzero == 1
elseif withzero == 0
    p2X = 0;
    for i = 1:1:length(p2k)
        p2k{i} = 0;
    end
else
    error('withzero can only be 0 or 1');
end

M = 1 + p2X*K;



%% Record ni
for i = 1:1:length(p2k)
    n{i} = length(equiv{i}.E) - 2;
end

%% Compute Matrices
N = length(p2k);
for i = 1:1:N
    A{i} = (equiv{i}.KiI * equiv{i}.C)/(Ad) - (p2k{i}*equiv{i}.KiI*K*equiv{i}.C)/(Ad*M);
end
A{N+1} = -(K)/(Ad*M);

for i = 1:1:N
    C{i} = (p2k{i}*equiv{i}.KiI*equiv{i}.C)/(M);
end
C{N+1} = 1/M;

for i = 1:1:N
    D{i} = (p2k{i}*equiv{i}.KiI*equiv{i}.D + p2k{i}*equiv{i}.L)/M;
end
D{N+1} = -(p2X*L)/M;

for i = 1:1:N
    mathds1= zeros(1,n{i}+2);
    mathds1(n{i}+1) = 1;
    F{i} = (p2k{i}*equiv{i}.KiI * equiv{i}.F)/M + (p2k{i}*mathds1)/M;
end
F{N+1} = -p2X/M;

for i = 1:1:N
    B{i} = -(K*D{i})/Ad + (equiv{i}.KiI*D{i})/Ad + (equiv{i}.L)/Ad;
end
B{N+1} = -L/Ad - (K*D{N+1})/Ad;

for i = 1:1:N
    mathds1= zeros(1,n{i}+2);
    mathds1(n{i}+1) = 1;
    E{i} = -(K*F{i})/Ad + (equiv{i}.KiI*equiv{i}.F)/Ad + (mathds1)/Ad;
end
E{N+1} = (K*p2X/(Ad*M))-1/Ad;
end