%%% Compute equivalent transfer functions parameters for merging conduits
%%% Input : the two input actual links and the one output link, input order does
%%% not matter, also a number k is needed to tell me which upstream level
%%% are you interested.
%%% Output: A model_link object,consists of transfer functions to determine the kth upstream level.

function output = elementary_link_merging_up(in1,in2,out,k)

if k == 1
    % %Compute G1(superscript 1 in writing document)
    deno = in1.p22*(out.p11-in2.p22) + in2.p22*out.p11;
    G1_1 = (in1.p21*(in2.p22-out.p11))/deno;
    G1_2 = (in2.p21*out.p11)/deno;
    G1_3 = -(in2.p22*out.p12)/deno;

    %Compute three transfer functions
    tf1 = in1.p11 + in1.p12*G1_1;
    tf2 = in1.p12*G1_2;
    tf3 = in1.p12*G1_3;
elseif k == 2
    %Compute G2(superscript 2 in writing document)
    deno = in1.p22*(out.p11-in2.p22) + in2.p22*out.p11;
    G2_1 = (in1.p21*out.p11)/deno;
    G2_2 = (in2.p21*(in1.p22-out.p11))/deno;
    G2_3 = -(in1.p22*out.p12)/deno;

    %Compute the transfer functions
    tf1 = in2.p12*G2_1;
    tf2 = in2.p11 + in2.p12*G2_2;
    tf3 = in2.p12*G2_3;
else
    error('k could only be 1 or 2 in elementary link merging')
end


output = model_link({tf1,tf2},tf3);
end


