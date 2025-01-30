%%% The function takes input data_input and string_input, where each is a
%%% cell array.
%%% We associate each name in string_input with an array in data_input.
function output = save_system_data(data_input,string_input)
for i = 1:1:length(data_input)
    data_input{i} = cell2mat(data_input{i});
    eval(string_input{i} + "= data_input{i}");
end

clearvars data_input string_input;
save('hurricane_dw.mat');
output = 1;
end

