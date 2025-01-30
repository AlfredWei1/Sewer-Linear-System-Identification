%%% This function applies the makeMinus Function to a cell array

function output = makeMinus_cell(input)
N = length(input);

output = cell(1,N);
for i = 1:1:N
    output{i} = makeMinus(input{i});
end
end