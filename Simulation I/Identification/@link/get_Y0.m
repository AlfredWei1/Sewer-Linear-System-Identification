function [output,x1,SX] = get_Y0(obj)
% Compute Y0(x) with assumption that YX = Yn(Qmax), Q0 = Qmax/2
Q0 = obj.Q0;
YX = obj.YX;

% Now compute SX
deno = ((obj.A(YX)).^2) * (obj.R(YX)).^(4/3);
Sf0_X = (Q0^2*obj.n^2)./deno;

%Compute Froude Number
F0_sq = (Q0^2*obj.T(YX))/(9.81*obj.A(YX)^3);

%Compute SX
SX = (obj.Sb - Sf0_X)/(1-F0_sq);

%Compute x1
%if abs(SX-0) >= 1e-7
if SX ~= 0
    x1 = max([obj.X - (YX-obj.Yn)/SX, 0]);
else
    x1 = obj.X;
end
% Note if YX < Yn, then x1>X, which is impossible, so we set x1 = X in that
% case
if x1 > obj.X
    x1 = obj.X;
end

%Compute Y1
if x1 ~= 0
    Y1 = obj.Yn;
else
    Y1 = YX-obj.X*SX;
%     Y1 = YX - obj.X*obj.Sb;
end

%Compute Y0(X)
% output = @(x) Y1*(x < x1) + (Y1+(x-x1)*obj.Sb).*(x >= x1);
output = @(x) Y1*(x < x1) + (Y1+(x-x1)*SX).*(x >= x1);
%output = @(x) output(x).* rectangularPulse(0,obj.X,x);
end

