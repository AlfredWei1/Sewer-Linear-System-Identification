%%% Compute equivalent transfer functions parameters for merging conduits
%%% Input : the two input links (at least one of them being model link) and 
%%% the one output actual link, input order does not matter.
%%% Output: A model_link object, consists of transfer functions to determine downstream level.


function output = model_link_merging(in1,in2,out)
% Note a result from elementary link merging is that all the d_level transfer
% functions in in1 have the same Ad and pinf.

% Firstly, cast both inputs as model_link
if isnan(in1.N_in)
    in1 = model_link({in1.p21},in1.p22);
end

if isnan(in2.N_in)
    in2 = model_link({in2.p21},in2.p22);
end

%% Now we start computing the quantities
% From p21 - p2n
% for i = 1:1:in1.N_in
%     Ad1 = i
% end
% 
% % From p2nbar - p2(m+n)
% for i = 1:1:in2.N_in
% end

% The p2(m+n)bar

%% Easy version for our particular case
Ad_eq = out.Ad*(in2.Ad_down + out.Au + in1.Ad_down)/(out.Au)
taud_eq_1 = in1.taud_up{1};
taud_eq_2 = in2.taud_up{1};
taud_eq_3 = in2.taud_up{2};

s = tf('s');
p21 = (1/(Ad_eq*s) + 0) *exp(-taud_eq_1*s);
p22 = (1/(Ad_eq*s) + 0) *exp(-taud_eq_2*s);
p23 = (1/(Ad_eq*s) + 0) *exp(-taud_eq_3*s);
p24 = -1/(Ad_eq*s) - 0;

output = model_link({p21,p22,p23},p24);


end



%
% if in2.N_in == 1 % Case where in2 is actual link
% 
%     % Compute first N_in transfer functions (how does in1's inflows affect yd)
%     for i = 1:1:in1.N_in
%         current_in1 = in1.p_up{i};
%         Ad{i} = current_in1.Denominator{1}(1);
%         taud{i} = current_in1.InputDelay;
%         p21_inf{i} = (current_in1.Numerator{1}(1))/(Ad{i});
% 
%         current_in1 = in1.p_down;
%         p22_inf{i} = (current_in1.Numerator{1}(1))/(current_in1.Denominator{1}(1));
% 
%         %Compute p2i for yd
%         Ad_eq = out.Ad*((in2.Ad + out.Au + Ad{i})/(out.Au));
%         taud_eq = taud{i} + out.taud;
%         p21_inf_eq = (-out.p21_inf*p21_inf{i}*in2.p22_inf)/(-p22_inf{i}*(out.p11_inf+in2.p22_inf)-in2.p22_inf*out.p11_inf);
% 
%         s = tf('s');
%         p2{i} = (1/(Ad_eq*s) + p21_inf_eq) *exp(-taud_eq*s);
%     end
% 
%     %Compute how in2's inflow affects yd
%     current_in1 = in1.p_down;
%     Ad = current_in1.Denominator{1}(1);
%     p22_inf =  (current_in1.Numerator{1}(1))/(Ad);
% 
%     Ad_eq = out.Ad*((in2.Ad + out.Au + Ad)/(out.Au));
%     taud_eq = in2.taud + out.taud;
%     p22_inf_eq = (out.p21_inf*in2.p21_inf*p22_inf)/(p22_inf*(out.p11_inf+in2.p22_inf)+in2.p22_inf*out.p11_inf);
%     
%     p2_in2 = (1/(Ad_eq*s)+ p22_inf_eq)*exp(-taud_eq*s);
% 
%     % Compute the last one (how outflow affect yd)
%     current_in1 = in1.p_down;
%     Ad = current_in1.Denominator{1}(1);
%     p22_inf =  (current_in1.Numerator{1}(1))/(Ad);
% 
%     Ad_eq = out.Ad*((in2.Ad + out.Au + Ad)/(out.Au));
%     p23_inf_eq = out.p22_inf + (in2.p22_inf*out.p12_inf*out.p21_inf - p22_inf*out.p12_inf*out.p21_inf)/(-p22_inf*(out.p11_inf+in2.p22_inf)-in2.p22_inf*out.p11_inf);
%     p2_last = -1/(Ad_eq*s) - p23_inf_eq;
% 
%     output = model_link(horzcat(p2,{p2_in2}),p2_last);
% elseif in2.N_in ~= 1 % Case where in2 is model link
% 
% end