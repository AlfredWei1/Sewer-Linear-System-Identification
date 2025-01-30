%%% Given ABECDF matrices, this function discretize the system using the
%%% time_step.

function [Ad,Bd,Ed,Cd,Dd,Fd] = discretize_matrices(A,B,E,C,D,F,time_step)
if iscell(A) == 0
    Ad = time_step*A + eye(length(A));
    Bd = time_step*B;
    Ed = time_step*E;
    Cd = C;
    Dd = D;
    Fd = F;
elseif iscell(A) == 1
    for i = 1:1:length(A) %%% This length is N+1
        Ad{i} = time_step*A{i};
        if i == length(A)
            Ad{i} = time_step*A{i} + 1;
        end

        Bd{i} = time_step*B{i};
        Ed{i} = time_step*E{i};
        Cd{i} = C{i};
        Dd{i} = D{i};
        Fd{i} = F{i};
    end
end
end