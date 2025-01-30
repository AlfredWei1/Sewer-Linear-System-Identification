function [p11,p12,p21,p22,p11_uni,p12_uni,p21_uni,p22_uni] = get_high(obj)
%Import backwater profile function handles
T0 = obj.T0;
A0 = obj.A0;
R0 = obj.R0;
P0 = obj.P0;
C0 = obj.C0;
V0 = obj.V0;
F0 = obj.F0;
dP0dY = obj.dP0dY;
dT0dY = obj.dT0dY;
kappa = obj.kappa;
gamma = obj.gamma;
delta = obj.delta;

%Placeholder
p11_uni = 0;
p12_uni = 0;
p21_uni = 0;
p22_uni = 0;

%If uniform part and backwater part both present:
if obj.x1 > 0 && obj.x1 < obj.X
    %%% For Uniform Part(_1), variables are at y=0, x=x1
    y = 0;
    x = obj.x1;

    %alpha compute
    alpha = (T0(y)*(2+(kappa(y)-1)*(F0(y).^2))*obj.Sb)./(A0(y)*F0(y)*(1-F0(y).^2));

    % p11_1 compute
    gain = 1./(T0(y)*C0(y)*(1-F0(y)));
    nume = 1 + (((1-F0(y))./(1+F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p11_1 = gain* sqrt(nume/deno);

    % p12_1 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = -gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p12_1 = gain*(nume/deno);

    %p21_1 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p21_1 = gain*(nume/deno);

    %p22_1 Compute
    gain = 1./(T0(y)*C0(y)*(1+F0(y)));
    nume = 1 + (((1+F0(y))./(1-F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p22_1 = gain* sqrt(nume/deno);

    %%% For Backwater Part(_2), variables are at y = x2 and x = X - x1
    y = obj.x2;
    x = obj.X - obj.x1;

    %Compute alpha
    term1 = T0(y)./(A0(y)*F0(y)*(1-F0(y).^2));
    term2 = (2+(kappa(y)-1)*F0(y).^2)*obj.Sb;
    term3 = 2 + (kappa(y)-1)*F0(y).^2;
    term4 = (A0(y)/T0(y).^2)*dT0dY(y) + kappa(y) -2;
    term5 = F0(y).^4;
    alpha = term1*(term2 - (term3 - term4*term5)*obj.SX);

    % p11_2 compute
    gain = 1./(T0(y)*C0(y)*(1-F0(y)));
    nume = 1 + (((1-F0(y))./(1+F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p11_2 = gain* sqrt(nume/deno);

    % p12_2 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = -gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p12_2 = gain*(nume/deno);

    %p21_2 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p21_2 = gain*(nume/deno);

    %p22_2 Compute
    gain = 1./(T0(y)*C0(y)*(1+F0(y)));
    nume = 1 + (((1+F0(y))./(1-F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p22_2 = gain* sqrt(nume/deno);


    %% Combine Two parts
    p11 = p11_1 + (p12_1*p21_1)/(p11_2 + p22_1);
    p12 = (p12_1*p12_2)/(p11_2 + p22_1);
    p21 = (p21_1*p21_2)/(p11_2 + p22_1);
    p22 = p22_2 + (p12_2*p21_2)/(p11_2 + p22_1);

elseif obj.x1 == obj.X %Only uniform part presents
%%% For Uniform Part(_1), variables are at y=0, x=x1
    y = 0;
    x = obj.x1;

    %alpha compute
    alpha = (T0(y)*(2+(kappa(y)-1)*(F0(y).^2))*obj.Sb)./(A0(y)*F0(y)*(1-F0(y).^2));

    % p11 compute
    gain = 1./(T0(y)*C0(y)*(1-F0(y)));
    nume = 1 + (((1-F0(y))./(1+F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p11 = gain* sqrt(nume/deno);

    % p12 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = -gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p12 = gain*(nume/deno);

    %p21 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p21 = gain*(nume/deno);

    %p22 Compute
    gain = 1./(T0(y)*C0(y)*(1+F0(y)));
    nume = 1 + (((1+F0(y))./(1-F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p22 = gain* sqrt(nume/deno);
elseif obj.x1 == 0     %Only backwater part presents
%%% For Backwater Part(_2), variables are at y = x2 and x = X - x1
    y = obj.x2;
    x = obj.X - obj.x1;

    %Compute alpha
    term1 = T0(y)./(A0(y)*F0(y)*(1-F0(y).^2));
    term2 = (2+(kappa(y)-1)*F0(y).^2)*obj.Sb;
    term3 = 2 + (kappa(y)-1)*F0(y).^2;
    term4 = (A0(y)/T0(y).^2)*dT0dY(y) + kappa(y) -2;
    term5 = F0(y).^4;
    alpha = term1*(term2 - (term3 - term4*term5)*obj.SX);

    % p11 compute
    gain = 1./(T0(y)*C0(y)*(1-F0(y)));
    nume = 1 + (((1-F0(y))./(1+F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p11 = gain* sqrt(nume/deno);

    % p12 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = -gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p12 = gain*(nume/deno);

    %p21 Compute
    gain = 2./(T0(y)*C0(y)*(1-F0(y).^2));
    exponent = gamma(y)*x/(2*T0(y)*(C0(y).^2-V0(y).^2));
    nume = exp(exponent);
    deno = sqrt(1 + exp(alpha*x));
    p21 = gain*(nume/deno);

    %p22 Compute
    gain = 1./(T0(y)*C0(y)*(1+F0(y)));
    nume = 1 + (((1+F0(y))./(1-F0(y))).^2 * exp(alpha*x));
    deno = 1 + exp(alpha*x);
    p22 = gain* sqrt(nume/deno);
end
end

