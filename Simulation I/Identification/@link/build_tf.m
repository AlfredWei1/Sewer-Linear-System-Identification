% Construct the integrator-delay-zero model given the parameters are
% computed, the outputs are matlab LTI transfer functions.

function [p11,p12,p21,p22] = build_tf(obj)
    s = tf('s');
    p11 = (1/(obj.Au*s)) + obj.p11_inf;
    p12 = -(1/(obj.Au*s) + obj.p12_inf)*exp(-obj.tauu*s);
    p21 = (1/(obj.Ad*s) + obj.p21_inf)*exp(-obj.taud*s);
    p22 = -1/(obj.Ad*s) - obj.p22_inf;
%     p11 = (1/(obj.Au*s));
%     p12 = -(1/(obj.Au*s))*exp(-obj.tauu*s);
%     p21 = (1/(obj.Ad*s))*exp(-obj.taud*s);
%     p22 = -1/(obj.Ad*s);
end

