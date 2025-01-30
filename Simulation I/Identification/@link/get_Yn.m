%Compute Normal Depth
function  [Yn_o,YX_o,N] = get_Yn(obj)
%%% Compute the normal depth with Q0 = Qmax/2,

% Set parameters
Q1 = obj.Qmax;
Q2 = obj.Qmin;
Q0 = obj.Q0;

%Compute f(Y) = friction slope - Sb
deno = @(Y) ((obj.A(Y)).^2) .* (obj.R(Y)).^(4/3);
sf0_1 = @(Y) (Q1^2*obj.n^2)./deno(Y) - obj.Sb;
sf0_2 = @(Y) (Q2^2*obj.n^2)./deno(Y) - obj.Sb;

%Find root f(Y)=0
Yn_Q1 = newton_rap(sf0_1,0.2);
Yn_Q2 = newton_rap(sf0_2,0.2);

if isnan(Yn_Q1) || isnan(Yn_Q2)
    error('Newton_Raphson Algorithm fails to find a solution.')
end

if ~isreal(Yn_Q1) || ~isreal(Yn_Q2)
    error('Newtion Raphson Returns nonreal numbers.')
end

N = 2*log(Q1/Q2)/log(Yn_Q1/Yn_Q2);

Yn_o = (Q0/Q1)^(2/N)*Yn_Q1;
YX_o = Yn_Q1;

end

