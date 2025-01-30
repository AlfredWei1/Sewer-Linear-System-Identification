%%% Compute equivalent transfer functions parameters for merging conduits
%%% Input : the two input actual links and the one output link, input order does
%%% not matter.
%%% Output: A model_link object.

function output = elementary_link_diverging(in,out1,out2)
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
tf1 = out.p21*G1_1 + out.p21*G1_2;
tf2 = out.p21*G2_1 + out.p21*G2_2;
tf3 = out.p22 + out.p21*G1_3 + out.p21*G2_3;

output = model_link({tf1,tf2},tf3);
end


