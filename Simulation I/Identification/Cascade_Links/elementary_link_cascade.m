%%% Compute equivalent transfer functions parameters for multiple conduits
%%% Uses Recursion, combines 2 links each iteration
%%% Input : the list of links, arranged in the order from upstream to
%%% downstream
%%% Output: A link object with only transfer functions (all other
%%% parameters are blank).

function output = elementary_link_cascade(list)
N = length(list);
if N == 2
    canal1 = list{1};
    canal2 = list{2};

    Au_1 = canal1.Au;
    Au_2 = canal2.Au;

    tauu_1 = canal1.tauu;
    tauu_2 = canal2.tauu;

    Ad_1 = canal1.Ad;
    Ad_2 = canal2.Ad;

    taud_1 = canal1.taud;
    taud_2 = canal2.taud;

    p11_inf_1 = canal1.p11_inf;
    p11_inf_2 = canal2.p11_inf;

    p12_inf_1 = canal1.p12_inf;
    p12_inf_2 = canal2.p12_inf;

    p21_inf_1 = canal1.p21_inf;
    p21_inf_2 = canal2.p21_inf;

    p22_inf_1 = canal1.p22_inf;
    p22_inf_2 = canal2.p22_inf;

    % Now compute the equivalent parameters as in Xavier Litrico
    % "Simplified Modelling of Irrigation Canals, appendix IV"
    Au = Au_1*(1 + Au_2/Ad_1);
    tauu = tauu_1 + tauu_2;
    Ad = Ad_2*(1 + Ad_1/Au_2);
    taud = taud_1 + taud_2;
    p11_inf = p11_inf_1 - (p12_inf_1*p21_inf_1)/(p11_inf_2 + p22_inf_1);
    p12_inf = (p12_inf_1*p12_inf_2)/(p11_inf_2 + p22_inf_1);
    p21_inf = (p21_inf_1*p21_inf_2)/(p11_inf_2 + p22_inf_1);
    p22_inf = p22_inf_2 - (p12_inf_2*p21_inf_2)/(p11_inf_2 + p22_inf_1);

    data = [Au,tauu,Ad,taud,p11_inf,p12_inf,p21_inf,p22_inf];

    %Construct the corresponding equivalent link
    output = link('_',data);

else
    output = elementary_link_cascade({elementary_link_cascade(list(1:N-1)),list{N}});
end

end

