%%% This function cascade an equivalent link to a simple link
%%% All the elements except for the first one in the list must be simple
%%% link. The first input must be a model link

%%% The inputs should be ordered from upstream to downstream.

function output = advanced_link_cascade(list)
N = length(list);

% Verify valid input
if isa(list{1},'model_link') == 0
    error('The first input should be an equivalent link.')
end
for i = 2:1:N
    if isa(list{i},'link') == 0
        error('All inputs except the first should be a simple link.')
    end
end

if N == 2
    canal1 = list{1};
    canal2 = list{2};

    Au_1 = canal1.Au;
    Au_2 = canal2.Au;
    Ad_1 = canal1.Ad;
    Ad_2 = canal2.Ad;

    tauuk_1 = canal1.tauuk;
    tauun_1 = canal1.tauun;
    taudk_1 = canal1.taudk;
    taudn_1 = canal1.taudn; % This is always 0
    tauu_2 = canal2.tauu;
    taud_2 = canal2.taud;

    p1k_inf_1 = canal1.p1k_inf;
    p1n_inf_1 = canal1.p1n_inf;
    p2k_inf_1 = canal1.p2k_inf;
    p2n_inf_1 = canal1.p2n_inf;
    p11_inf_2 = canal2.p11_inf;
    p12_inf_2 = canal2.p12_inf;
    p21_inf_2 = canal2.p21_inf;
    p22_inf_2 = canal2.p22_inf;

    % Start Computation if first link contains both upstream and downstream
    if ~isnan(Au_1) && ~isnan(Au_2)
        Au = Au_1*(1 + Au_2/Ad_1);
        Ad = Ad_2*(1 + Ad_1/Au_2);
    
        tauuk = tauuk_1;
        tauun = tauun_1;
        tauu = tauun_1 + tauu_2;
        taudk = num2cell(cell2mat(taudk_1) + taud_2);
        taudn = taud_2;
        
        for i = 1:1:canal1.n
            p1k_inf{i} = p1k_inf_1{i} - (p1n_inf_1*p2k_inf_1{i})/(p11_inf_2 + p2n_inf_1);
        end
        p1n_inf = (p1n_inf_1*p11_inf_2)/(p11_inf_2 + p2n_inf_1);
        p1np1_inf = (p1n_inf_1*p12_inf_2)/(p11_inf_2 + p2n_inf_1);
    
        for i = 1:1:canal1.n
            p2k_inf{i} = (p21_inf_2 * p2k_inf_1{i})/(p11_inf_2 + p2n_inf_1);
        end
        p2n_inf = (p21_inf_2*p2n_inf_1)/(p11_inf_2 + p2n_inf_1);
        p2np1_inf = p22_inf_2 - (p21_inf_2*p12_inf_2)/(p11_inf_2 + p2n_inf_1);

    % Start computation if first link only contains downstream
    else
        Au = nan;
        Ad = Ad_2*(1 + Ad_1/Au_2);
    
        tauuk = tauuk_1;
        tauun = tauun_1;
        tauu = nan;
        taudk = num2cell(cell2mat(taudk_1) + taud_2);
        taudn = taud_2;
        
        for i = 1:1:canal1.n
            p1k_inf{i} = nan;
        end
        p1n_inf = nan;
        p1np1_inf = nan;
    
        for i = 1:1:canal1.n
            p2k_inf{i} = (p21_inf_2 * p2k_inf_1{i})/(p11_inf_2 + p2n_inf_1);
        end
        p2n_inf = (p21_inf_2*p2n_inf_1)/(p11_inf_2 + p2n_inf_1);
        p2np1_inf = p22_inf_2 - (p21_inf_2*p12_inf_2)/(p11_inf_2 + p2n_inf_1);
    end

    % Construct transfer functions from the above parameters
    s = tf('s');
    if ~isnan(Au_1) && ~isnan(Au_2)
        for i = 1:1:canal1.n
            p1k{i} = (1/(Au*s) + p1k_inf{i})*exp(-tauuk{i}*s);
            p2k{i} = (1/(Ad*s) + p2k_inf{i})*exp(-taudk{i}*s);
        end
        p1n = (1/(Au*s) + p1n_inf)*exp(-tauun*s);
        p2n = (1/(Ad*s) + p2n_inf)*exp(-taudn*s);
        p1np1 = -(1/(Au*s) + p1np1_inf)*exp(-tauu*s);
        p2np1 = -(1/(Ad*s) + p2np1_inf);
    else
        for i = 1:1:canal1.n
            p1k{i} = nan;
            p2k{i} = (1/(Ad*s) + p2k_inf{i})*exp(-taudk{i}*s);
        end
        p1n = nan;
        p2n = (1/(Ad*s) + p2n_inf)*exp(-taudn*s);
        p1np1 = nan;
        p2np1 = -(1/(Ad*s) + p2np1_inf);
    end

    % Form the resultant equivalent link
    p_up = cell(1,canal1.n+1);
    p_down = cell(1,canal1.n+1);
    for i = 1:1:canal1.n
        p_up{i} = p1k{i};
        p_down{i} = p2k{i};
    end
    p_up{canal1.n+1} = p1n;
    p_down{canal1.n+1} = p2n;

    output = model_link(p_up,p1np1,p_down,p2np1);


else
    output = advanced_link_cascade({advanced_link_cascade(list(1:N-1)),list{N}});
end
end