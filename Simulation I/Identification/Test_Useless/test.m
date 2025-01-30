clear;
clc;

Q1 = 80;
Q2 = Q1/8;
X = 6000;
m = 1.5;
B = 8;
Sb = 0.0008;
n = 0.02;

f = @(Q,Y) (Q^2*n^2)/(((B*Y+m*Y^2)^2) * ((B*Y+m*Y^2)/(B+2*Y*sqrt(1+m^2)))^(4/3)) - Sb;

g1 = @(Y) f(Q1,Y);
g2 = @(Y) f(Q2,Y);

%Choose initialization
Y_0 = 2;

Yn_Q1 = newton_rap(g1,2);
Yn_Q2 = newton_rap(g2,0.8);

N = 2*log(Q1/Q2)/log(Yn_Q1/Yn_Q2);

%% Compute x1
Q0 = Q1/2;
YX = Yn_Q1;
Yn = (Q0/Q1)^(2/N)*Yn_Q1;


Sf0_X = (Q0^2*n^2)/(((B*YX+m*YX^2)^2) * ((B*YX+m*YX^2)/(B+2*YX*sqrt(1+m^2)))^(4/3));
F0_sq = (Q0^2*(B+2*m*YX))/(9.81*(B*YX+m*YX^2)^3);
SX = (Sb-Sf0_X)/(1-F0_sq);

x1 = max([X-(YX-Yn)/SX,0]);
