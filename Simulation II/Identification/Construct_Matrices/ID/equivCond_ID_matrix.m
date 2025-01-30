%%% This function takes in the equivalent conduit and the linear gains
%%% associated to the two orifices. As the outputs, it returns the
%%% A^i,B^i,E^i,C^i,D^i, and F^i matrices. The withzero factor determines
%%% whether we want the zero in our final model or not.

%%% We note these matrices are in continuous-time.

function [A,B,E] = equivCond_ID_matrix(conduit,KCSO,KI,L,withzero)
K = KCSO + KI;
Ad = conduit.Ad;



%% Compute Matrices
A = -K/(Ad);

B = -L/Ad;

E = [];
for i = 1:1:length(p2k)
    E = [E, 1/Ad];
end
E = [E, -1/Ad, -1/Ad];
end