function [AI,BI,EI] = interceptor_ID_matrix(conduit,K,L,equiv_K,equiv_L,n)
AdI = conduit.Ad;

N = length(conduit.p2k);
for i = 1:1:N
    AI{i} = equiv_K(i)/AdI;
    BI{i} = equiv_L(i)/AdI;
end

AI{N+1} = -K/AdI;
BI{N+1} = -L/AdI;

for i = 1:1:N
    mathds1= zeros(1,n{i}+2);
    mathds1(n{i}+1) = 1;
    EIsub{i} = (1/AdI)*mathds1; 
end

EIsub{N+1} = -1/AdI;

EI = [];
for i  = 1:1:N+1
    EI = [EI,EIsub{i}];
end
