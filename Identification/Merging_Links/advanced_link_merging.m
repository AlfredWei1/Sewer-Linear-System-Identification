%%% This function merges two incoming conduits and one outflowing conduit.

function output = advanced_link_merging(list)
N = length(list);

% Verify valid input
if isa(list{1},'model_link') == 0
    error('The first input should be an equivalent link.')
end
if isa(list{2},'model_link') == 0
    error('The second input should be an equivalent link.')
end
if isa(list{3},'link') == 0
    error('The third input should be a simple link.')
end

% Start reading

C1 = list{1};
C2 = list{2};
C3 = list{3};

Au_1 = C1.Au;
Au_2 = C2.Au;
Au_3 = C3.Au;
Ad_1 = C1.Ad;
Ad_2 = C2.Ad;
Ad_3 = C3.Ad;

taudk_1 = C1.taudk;
taudn_1 = C1.taudn;
taudj_2 = C2.taudk;
taudm_2 = C2.taudn;
taud_3 = C3.taud;

p1k_inf_1 = C1.p1k_inf;
p1n_inf_1 = C1.p1n_inf;
p2k_inf_1 = C1.p2k_inf;
p2n_inf_1 = C1.p2n_inf;
p1j_inf_2 = C2.p1k_inf;
p1m_inf_2 = C2.p1n_inf;
p2j_inf_2 = C2.p2k_inf;
p2m_inf_2 = C2.p2n_inf;
p11_inf_3 = C3.p11_inf;
p12_inf_3 = C3.p12_inf;
p21_inf_3 = C3.p21_inf;
p22_inf_3 = C3.p22_inf;

% Start computing
Ad = Ad_3*((Ad_2 + Ad_1 + Au_3)/Au_3);

taudk = num2cell(cell2mat(taudk_1) + taud_3);
taudj = num2cell(cell2mat(taudj_2) + taud_3);
taudl = taud_3;

for k = 1:1:C1.n
    p2k_inf{k} = (p21_inf_3*p2m_inf_2*p2k_inf_1{k})/(p2n_inf_1*p11_inf_3 + p11_inf_3*p2m_inf_2 + p2n_inf_1*p2m_inf_2); 
end
for j = 1:1:C2.n
    p2j_inf{j} = (p21_inf_3*p2n_inf_1*p2j_inf_2{j})/(p2n_inf_1*p11_inf_3 + p11_inf_3*p2m_inf_2 + p2n_inf_1*p2m_inf_2);
end
p2l_inf = (p21_inf_3*p2n_inf_1*p2m_inf_2)/(p2n_inf_1*p11_inf_3 + p11_inf_3*p2m_inf_2 + p2n_inf_1*p2m_inf_2);
p2X_inf = p22_inf_3 - (p21_inf_3*p12_inf_3*(p2m_inf_2 + p2n_inf_1))/(p2n_inf_1*p11_inf_3 + p11_inf_3*p2m_inf_2 + p2n_inf_1*p2m_inf_2);

% Form transfer functions
s = tf('s');
for k = 1:1:C1.n
    p2k{k} = (1/(Ad*s) + p2k_inf{k})*exp(-taudk{k}*s);
end
for j = 1:1:C2.n
    p2j{j} = (1/(Ad*s) + p2j_inf{j})*exp(-taudj{j}*s);
end
p2l = (1/(Ad*s) + p2l_inf)*exp(-taudl*s);
p2X = -(1/(Ad*s) + p2X_inf);

% Define p1k,p1l, and p1X to be nan


% Form the resultant equivalent link
n = C1.n;
m = C2.n;
p_up = cell(1,n+m+1);
p_down = cell(1,n+m+1);
for i = 1:1:n
    p_up{i} = nan;
    p_down{i} = p2k{i};
end
for i = 1:1:m
    p_up{n+i} = nan;
    p_down{n+i} = p2j{i}; 
end
p_up{n+m+1} = nan;
p_down{n+m+1} = p2l;

output = model_link(p_up,nan,p_down,p2X);
end

