function [Au,Ad,tauu,taud,Au_uni,Ad_uni,tauu_uni,taud_uni] = get_low(obj)
%Compute the transfer matrix parameters for low frequencies
%Import backwater profile function handles
T0 = obj.T0;
A0 = obj.A0;
R0 = obj.R0;
P0 = obj.P0;
C0 = obj.C0;
V0 = obj.V0;
F0 = obj.F0;
dP0dY = obj.dP0dY;
alpha = obj.alpha;
beta = obj.beta;
kappa = obj.kappa;
gamma = obj.gamma;
delta = obj.delta;

%Return the parameters in the uniform case
% y = 0;
% x = obj.X;

% [gain,exponent] = gain_exponent(obj,y,x);
% Au_uni = gain*(exp(exponent)-1);
% Ad_uni = gain*(1-exp(-exponent));
% taud_uni = x/alpha(y);
% tauu_uni = x/beta(y);

Au_uni = 0;
Ad_uni = 0;
taud_uni = 0;
tauu_uni = 0;


%%%We let the backwater profiles evaluated at y

% We first compute the case where uniform part and backwater part both
% present
if obj.x1 > 0 && obj.x1 < obj.X % The both present case

    %Compute Ad_1 and Au_1, evaluated at x = x1, y = 0
    y = 0;
    x = obj.x1;
    
    [gain,exponent] = gain_exponent(obj,y,x);
    Au_1 = gain*(exp(exponent)-1);
    Ad_1 = gain*(1-exp(-exponent));
    
    %Compute Ad_2 and Au_2, evaluated at x = X-x1, y = x2
    y = obj.x2;
    x = obj.X-obj.x1;
    
    [gain,exponent] = gain_exponent(obj,y,x);
    Au_2 = gain*(exp(exponent)-1);
    Ad_2 = gain*(1-exp(-exponent));
    
    %Compute taud_1 and tauu_1, evaluated at x = x1, y = 0
    y = 0;
    x = obj.x1;
    
    taud_1 = x/alpha(y);
    tauu_1 = x/beta(y);
    
    
    %Compute taud_2 and tauu_2, evaluated at x = X-x1, y = x2
    y = obj.x2;
    x = obj.X-obj.x1;
    
    taud_2 = x/alpha(y);
    tauu_2 = x/beta(y);
    
    %Compute actual quantities
    tauu = tauu_1 + tauu_2;
    taud = taud_1 + taud_2;
    Au = Au_1 * (1 + (Au_2/Ad_1));
    Ad = Ad_2 * (1 + (Ad_1/Au_2));

elseif obj.x1 == obj.X % The pure uniform case
    y = obj.x1/2; %Actually any value is fine
    x = obj.X;

    [gain,exponent] = gain_exponent(obj,y,x);
    Au = gain*(exp(exponent)-1);
    Ad = gain*(1-exp(-exponent));
    tauu = x/beta(y);
    taud = x/alpha(y);
elseif obj.x1 == 0
    y = obj.x2;
    x = obj.X-obj.x1;

    [gain,exponent] = gain_exponent(obj,y,x);
    Au = gain*(exp(exponent)-1);
    Ad = gain*(1-exp(-exponent));
    tauu = x/beta(y);
    taud = x/alpha(y);
end


end
