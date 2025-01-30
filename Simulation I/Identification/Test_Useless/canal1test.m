clear;
clc;

X = 3000;
m = 1.5;
B = 7;
Sb = 0.0001;
n = 0.02;
Qmax = 14;
Qmin = 1.75;
N = 3.51;
YX = 2.12;

Q0_ar = linspace(Qmin,Qmax,100);
i = 1;
for Q0 = Q0_ar
    [Ad{i},taud{i}] = canal1(Q0);
    i = i+1;
end

Q = linspace(Qmin,Qmax,100);
plot(Q,cell2mat(Ad));
