function [gain,exponent] = gain_exponent(obj,y,x)
%Import backwater profile function handles
T0 = obj.T0;
C0 = obj.C0;
V0 = obj.V0;
alpha = obj.alpha;
beta = obj.beta;
gamma = obj.gamma;

% Old gain/exponent from 53
gain = (T0(y)^2*(C0(y)^2-V0(y)^2))/gamma(y);
exponent = (gamma(y)*x)/(T0(y)*(C0(y)^2-V0(y)^2));

% New gain/exponent from textbook
% gain = (T0(y)*alpha(y)*beta(y))/gamma(y);
% exponent = (gamma(y)*x)/(alpha(y)*beta(y));
end

