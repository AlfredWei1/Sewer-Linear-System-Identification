function x_star = newton_rap(f,x_0)
%%% This function computes the root x^* to f(x)=0 using newton-rapson,
%%% given the initialization is x_0
%%% f is a function handle (not numeric)
small = 1e-6;
df = @(x) (f(x+small)-f(x))/small;

x = [x_0-0.1, x_0]; %x_0-0.1 is just auxiliary
n = 2;

while abs(x(n)-x(n-1)) > 0.001
    increment = f(x(n))/df(x(n));
    x = [x x(n) - increment];
    n = n+1;
end
x_star = x(n);


end

 