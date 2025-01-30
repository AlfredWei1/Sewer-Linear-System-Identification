%%% Compute equivalent transfer functions parameters for merging conduits
%%% Input : the two input actual links and the one output actual link, input order does
%%% not matter.
%%% Output: A model_link object, consists of transfer functions to determine downstream level.

function output = elementary_link_merging(in1,in2,out)

%% Exact Transfer Functions
% %Compute G1(superscript 1 in writing document)
deno = in1.p22*(out.p11-in2.p22) + in2.p22*out.p11;
G1_1 = (in1.p21*(in2.p22-out.p11))/deno;
G1_2 = (in2.p21*out.p11)/deno;
G1_3 = -(in2.p22*out.p12)/deno;

%Compute G2(superscript 2 in writing document)
deno = in1.p22*(out.p11-in2.p22) + in2.p22*out.p11;
G2_1 = (in1.p21*out.p11)/deno;
G2_2 = (in2.p21*(in1.p22-out.p11))/deno;
G2_3 = -(in1.p22*out.p12)/deno;

%Compute 3 resulting transfer functions
tf1 = out.p21*G1_1 + out.p21*G2_1;
tf2 = out.p21*G1_2 + out.p21*G2_2;
tf3 = out.p22 + out.p21*G1_3 + out.p21*G2_3;

% output = model_link({tf1,tf2},tf3);

%% Approximate Model

%Compute p21 for yd
Ad_eq = out.Ad*((in2.Ad + out.Au + in1.Ad)/(out.Au));
taud_eq = in1.taud + out.taud;
p21_inf_eq = (-out.p21_inf*in1.p21_inf*in2.p22_inf)/(-in1.p22_inf*(out.p11_inf+in2.p22_inf)-in2.p22_inf*out.p11_inf);

s = tf('s');
p21 = (1/(Ad_eq*s) + p21_inf_eq) *exp(-taud_eq*s);

%Compute p22 for yd
Ad_eq = out.Ad*((in2.Ad + out.Au + in1.Ad)/(out.Au));
taud_eq = in2.taud + out.taud;
p22_inf_eq = (out.p21_inf*in2.p21_inf*in1.p22_inf)/(in1.p22_inf*(out.p11_inf+in2.p22_inf)+in2.p22_inf*out.p11_inf);

p22 = (1/(Ad_eq*s)+ p22_inf_eq)*exp(-taud_eq*s);

%Compute p23 for yd
Ad_eq = out.Ad*((in2.Ad + out.Au + in1.Ad)/(out.Au));
p23_inf_eq = out.p22_inf + (in2.p22_inf*out.p12_inf*out.p21_inf - in1.p22_inf*out.p12_inf*out.p21_inf)/(-in1.p22_inf*(out.p11_inf+in2.p22_inf)-in2.p22_inf*out.p11_inf);
p23 = -1/(Ad_eq*s) - p23_inf_eq;



% p21 = C13.p21;
% p22 = C23.p21;
% % p23 = (C13.p22+C23.p22)/2;
% p23 = out.p22;
% 
% f = linspace(0,1,10e3);
% y1 = [];
% y2 = [];
% for i = f
%     y1 = [y1 evalfr(tf1,i)];
%     y2 = [y2 evalfr(p21,i)];
% end
% figure;
% plot(f,y1)
% hold on;
% plot(f,y2)
% legend('tf1','p21');

% a=3;


% figure;
% bode(p21); % p21 is appriximation as an IDZ model
% hold on;
% bode(tf1); % tf1 is the actual
% legend('p21','tf1');
% 
% figure;
% bode(p22); % p21 is appriximation as an IDZ model
% hold on;
% bode(tf2); % tf1 is the actual
% legend('p22','tf2');
% 
% figure;
% bode(p23); % p21 is appriximation as an IDZ model
% hold on;
% bode(tf3); % tf1 is the actual
% legend('p23','tf3');
output = model_link({p21,p22},p23);
end

