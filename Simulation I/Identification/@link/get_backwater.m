function [T0,A0,R0,P0,C0,V0,F0,dP0dY,dT0dY,alpha,beta,kappa,gamma,delta] = get_backwater(obj)
% Now we know the equilibrium depth Y0(x), all other equilibrium quantities
% can be computed.
Y0 = obj.Y0;
Q0 = obj.Q0;
d = 1e-5;

T0 = @(x) obj.T(Y0(x));
A0 = @(x) obj.A(Y0(x));
R0 = @(x) obj.R(Y0(x));
P0 = @(x) obj.P(Y0(x));
C0 = @(x) sqrt((9.81*A0(x))./T0(x));
V0 = @(x) Q0./A0(x);
F0 = @(x) V0(x)./C0(x);
dP0dY = @(x) obj.dPdY(Y0(x));
dT0dY = @(x) obj.dTdY(Y0(x));
alpha = @(x) C0(x)+V0(x);
beta = @(x) C0(x)-V0(x);

% Report error if F0 > 1, this violates our assmption
if F0(0) >= 1 || F0(obj.X) >= 1
    error("Froude Number is larger than 1, which violates assumption.")
end

%Kappa
kappa = @(x) 7/3 - ((4*A0(x))/(3*T0(x).*P0(x))) * dP0dY(x);

%gamma consists of a lot of terms, break up:
dT0dx  = @(x) (T0(x+d)-T0(x))/d;
dY0dx = @(x) (Y0(x+d) - Y0(x))/d;

%The new gamma textbook
% term1 = @(x) ((C0(x).^2)/T0(x)).* dT0dx(x);
% term2 = @(x) (1+kappa(x))*obj.Sb;
% term3 = @(x) 1+kappa(x) - (kappa(x)-2).*(F0(x).^2);
% term4 = @(x) dY0dx(x);
% gamma = @(x) term1(x) + 9.81*(term2(x) - term3(x).*term4(x));

%The old gamma [53]
term1 = @(x) (V0(x).^2).*dT0dx(x);
term2 = @(x) (1+kappa(x))*obj.Sb;
term3 = @(x) 1+kappa(x) - (kappa(x)-2).*(F0(x).^2);
term4 = @(x) dY0dx(x);
gamma = @(x) term1(x) + (9.81*T0(x)).*(term2(x) - term3(x).*term4(x));

%delta
term = @(x) (2*9.81)./(V0(x));
delta = @(x) term(x).*(obj.Sb - dY0dx(x));

end



