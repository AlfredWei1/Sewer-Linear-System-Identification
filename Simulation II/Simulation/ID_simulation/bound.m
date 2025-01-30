function output = bound(input)
output = zeros(length(input),1);
for i = 1:1:length(input)
    if input(i) >= 0
        output(i) = 0;
    elseif input(i) <= -1
        output(i) = -1;
    else
        output(i) = input(i);
    end
end
end