%%%This class models generalized links. When we encounter merging 
%%%in the system, we could  model the conduits connected with a
%%%generalized conduit with multiple input flows and one outflow.

%%% When we simplify a topology with more than one merging nodes, the
%%% number of input flows can go arbitrarily large.

%%% We are only interested in the downstream storage level in our
%%% modelling.

classdef model_link
    properties
        %%% Note all quantities with k are cell arrays

        n    % Number of input flows
        p1k    % A cell array of transfer functions taking N_in inflows as input
        p1n    % A transfer function relating yd to storage outflow
        p2k
        p2n

        Au
        Ad
        tauuk
        tauun
        taudk
        taudn  % This is always 0
        p1k_inf
        p1n_inf
        p2k_inf
        p2n_inf
    end
    
    methods
        %The constructor of the class
        function obj = model_link(p1k,p1n,p2k,p2n)
            obj.n = length(p1k);
            obj.p1k = p1k;
            obj.p1n = p1n;
            obj.p2k = p2k;
            obj.p2n = p2n;
            
            if isa(p1n,'tf') == 1
                % For p1n parameters
                deno = cell2mat(p1n.Denominator);
                nume = cell2mat(p1n.Numerator);
    %             obj.Aun = deno(1);
                obj.Au = deno(1);
                obj.p1n_inf = -nume(1)/obj.Au;
                obj.tauun = p1n.InputDelay;
                
                % For p1k parameters
                for i = 1:1:obj.n
                    deno = cell2mat(p1k{i}.Denominator);
                    nume = cell2mat(p1k{i}.Numerator);
    %                 obj.Auk{i} = deno(1);
                    obj.p1k_inf{i} = nume(1)/obj.Au;
                    obj.tauuk{i} = p1k{i}.InputDelay;
                end
            else
                obj.Au = nan;
                obj.p1n_inf = nan;
                obj.tauun = nan;
                for i = 1:1:obj.n
                    obj.p1k_inf{i} = nan;
                    obj.tauuk{i} = nan;
                end
            end
            
            % For p2n parameters
            deno = cell2mat(p2n.Denominator);
            nume = cell2mat(p2n.Numerator);
%             obj.Adn = deno(1);
            obj.Ad = deno(1);
            obj.p2n_inf = -nume(1)/obj.Ad;
            obj.taudn = p2n.InputDelay;

            % For p2k parameters
            for i = 1:1:obj.n
                deno = cell2mat(p2k{i}.Denominator);
                nume = cell2mat(p2k{i}.Numerator);
%                 obj.Adk{i} = deno(1);
                obj.p2k_inf{i} = nume(1)/obj.Ad;
                obj.taudk{i} = p2k{i}.InputDelay;
            end


        end
        
    end
end

