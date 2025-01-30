%%% This function takes in the equivalent conduit and the linear gains
%%% associated to the two orifices. As the outputs, it returns the
%%% A^i,B^i,E^i,C^i,D^i, and F^i matrices. The withzero factor determines
%%% whether we want the zero in our final model or not.

%%% We note these matrices are in continuous-time.

function [A,B,E,C,D,F] = equivCond_matrix(conduit,KCSO,KI,L,withzero)
K = KCSO + KI;

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



%% Compute Matrices
A = -K/(Ad*M);

B = (K*p2X*L)/(Ad*M) - L/Ad;

E = [];
for i = 1:1:length(p2k)
    E = [E, 1/Ad - (K*p2k{i})/(Ad*M)];
end
E = [E, (K*p2X)/(Ad*M) - 1/Ad, (K*p2X)/(Ad*M) - 1/Ad];

C = 1/M;
D = -(p2X*L)/M;
F = [];
for i = 1:1:length(p2k)
    F = [F, p2k{i}/M];
end
F = [F, -p2X/M, -p2X/M];
end