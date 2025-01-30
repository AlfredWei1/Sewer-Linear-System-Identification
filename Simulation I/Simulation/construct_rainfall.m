function new_rainfall = construct_rainfall(raintable,N)

new_rainfall = zeros(1,N);
for i = 1:1:length(raintable.Var3)
    current_pre = raintable.Var3(i);
    new_rainfall(72*(i-1)+1:72*i) = current_pre*ones(1,72);
end

new_rainfall = new_rainfall(1:N);

end