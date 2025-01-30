function [Ad,taud] = canal1(Q0)
X = 3000;
m = 1.5;
B = 7;
Sb = 0.0001;
n = 0.02;
Qmax = 14;
Qmin = 1.75;
N = 3.51;
YX = 2.12;
bank = @(x) -Sb*x + (Sb*X);
t = linspace(0,X,1000);
d = 1e-3;

%Compute Yn at Q0
Yn = ((Q0/Qmax)^(2/N)) *YX;
fprintf('Yn = %f\n',Yn);

%Compute Sf0 at YX
nume = (Q0^2)*(n)^2;
deno1 = ((B+m*YX)*YX)^2;
deno2 = (((B+m*YX)*YX)/(B+2*YX*sqrt(1+m^2)))^(4/3);
Sf0X = nume/(deno1*deno2);
fprintf('Sf0X = %f\n',Sf0X);

%Compute F0 at YX
nume = Q0;
deno1 = (B+m*YX)*YX;
deno2 = sqrt((9.81)*((B+m*YX)*YX)/(B+2*m*YX));
F0X = nume/(deno1*deno2);
fprintf('F0X = %f\n',F0X);

%Compute SX
SX = (Sb - Sf0X)/(1-F0X^2);
fprintf('SX = %f\n',SX);

%Compute x1
if SX ~= 0
    x1 = max([X - (YX-Yn)/SX,0]);
elseif SX == 0
    x1 = X;
end
fprintf('x1 = %f\n',x1);

%Compute x2
x2 = (x1+X)/2;
fprintf('x2 = %f\n',x2);

%Compute Y1
if x1 ~= 0
    Y1 = Yn;
elseif x1 == 0
    Y1 = YX - X*SX;
end
fprintf('Y1 = %f\n',Y1);

%Compute Y0 at 0 and x2
Y0 = @(x) Y1 + (x - x1)*SX; % A point to change, note this is different form paperrrrrrrr
Y0_0 = Y0(0);
Y0_x2 = Y0(x2);
Y0_X = Y0(X);
fprintf('Y0(0) = %f\n',Y0_0);
fprintf('Y0(x2) = %f\n',Y0_x2);
fprintf('Y0(X) = %f\n',Y0_X);
fprintf('D(0) = %f\n',Y0_0 + bank(0));
fprintf('D(x2) = %f\n',Y0_x2 + bank(x2));
fprintf('D(X) = %f\n',Y0_X + bank(X));


% Compute backwater profiles
A = @(Y) (B*Y+m*Y.^2); 
T = @(Y) (B+2*m*Y);
R = @(Y) ((B*Y+m*Y.^2)./(B+2*sqrt(1+m^2)*Y));
P = @(Y) A(Y)./R(Y);
dPdY = @(Y) 2*sqrt(1+m^2);

T0 = @(x) T(Y0(x));
A0 = @(x) A(Y0(x));
R0 = @(x) R(Y0(x));
P0 = @(x) P(Y0(x));
C0 = @(x) sqrt((9.81*A0(x))./T0(x));
V0 = @(x) Q0./A0(x);
F0 = @(x) V0(x)./C0(x);
dP0dY = @(x) dPdY(Y0(x));
alpha = @(x) C0(x)+V0(x);
beta = @(x) C0(x)-V0(x);
kappa = @(x) 7/3 - ((4*A0(x))/(3*T0(x).*P0(x))) * dP0dY(x);
dT0dx  = @(x) (T0(x+d)-T0(x))/d;
dY0dx = @(x) (Y0(x+d) - Y0(x))/d;
term1 = @(x) ((C0(x).^2)/T0(x)).* dT0dx(x);
term2 = @(x) (1+kappa(x))*Sb;
term3 = @(x) 1+kappa(x) - (kappa(x)-2).*(F0(x).^2);
term4 = @(x) dY0dx(x);
gamma = @(x) term1(x) + 9.81*(term2(x) - term3(x).*term4(x));

%Compute Ad and taud
y = x2;
x = X-x1;
gain = (T0(y)*alpha(y)*beta(y))/gamma(y);
exponent = (gamma(y)*x)/(alpha(y)*beta(y));
Ad = gain*(1-exp(-exponent));
taud = x/(C0(y)+V0(y));

end

