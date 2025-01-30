%%% An equivalent conduit has ABECDF matrices, this function record the
%%% continuous-time matrices for later uses. It also stores the K^i_I
%%% quantity

classdef link_matrices
    properties
        A
        B
        E
        C
        D
        F
        KiI
        L
    end
    methods
        % The constructor of the class
        function obj = link_matrices(A,B,E,C,D,F,KiI,L)
            obj.A = A;
            obj.B = B;
            obj.E = E;
            obj.C = C;
            obj.D = D;
            obj.F = F;
            obj.KiI = KiI;
            obj.L = L;
        end
    end
end