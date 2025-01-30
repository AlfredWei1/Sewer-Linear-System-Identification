%%% This class contains all properties associated to a conduit, all
%%% computations are done in the initialization.

%%% Reference: Analytical approximation of open-channel flow
%%%            for controller design

%%% Initialize as  = link('shape',{X,n,Sb,Q,YX,geo_para})

% Here Q = [Qmax,Qmin,Q0], you must specify all.

% Here YX is the downstream water depth, put 0 if not avaliable.
% If YX = 0, then YX is set to Yn(Qmax)

% Here Yn is the upstream water depth, put 0 if not avaliable.
% If Yn = 0, then Yn is set to the normal depth.

classdef link
    
    properties (SetAccess=public)
        shape % Shape of Channel: 'trapezoid','rectangular','circular'
        X     % length
        n     % Manning roughness coefficient
        Sb    % Bed Slope
        Qmax  % Maximum downstram Flow, input 0 if not avaliable
        geo_para % Geometric parameters witht the shape
                 % Trapezoid: [B,m]
                 % Rectangular: b
                 % Circular: 
        YX    % The user-specified downstream water depth, put 0 if not avaliable
        Y_up  % The user-specified upstream water depth, put 0 if not avaliable
        N_in  % Always nan in this case, created to distinguish from model_link

               
        A        % Convert depth to wetted area, function of Y
        T        % Convert depth to top width, function of Y
        R        % Convert depth to hydraulic radius, function of Y
        P        % Convert depth to perimeter, function of Y
        dPdY     % The derivative dP/dY, function of Y
        dTdY     % The derivative dT/dT, function of Y
        manning  % The manning's equation as a function of Y
        dmanning % The derivative of manning's equation

        Q0       % The flow condition we are working around
        Qmin     % The second quantity for N computation, the first is Qmax
        Yn       % The Normal Depth
        N        % The approximation exponent
        %YX       % Yn(Qmax) by assumption
        x1       % The uniform depth/backwater depth dividing point
        x2       % x2 = (x1+X)/2
        Y0       % The Backwater curve, function of x, with assumption YX = Yn(Qmax)

        %The backwater profiles
        T0       % The top width, function of x
        A0       % Wetted area, functiono of x
        R0       % Hydraulic Radius, functiono of x
        P0       % Perimeter, function of x
        C0       % Supplementary quantity
        V0       % Velocity
        F0       % Froude Number
        dP0dY    % Equals (dPdY)(Y0(x))
        dT0dY    % Equals (dTdY)(Y0(x))
        alpha    % C0+V0
        beta     % C0-V0
        kappa   % Supp
        gamma   % Supp
        delta    % Supp
        SX      %Backwater part slope

        %Transfer Function Quantities (Low Frequency)
        Au   % Integrator gain of upstream level
        Ad   % Integrator gain of downstream level
        tauu % Delay from downstream to upstream
        taud % Delay from upstream to downstream       

        %Transfer Function Quantities (High Frequency)
        p11_inf
        p12_inf
        p21_inf
        p22_inf

        %Transfer Function Quantities (Uniform Part)
        Au_uni
        Ad_uni
        tauu_uni
        taud_uni
        p11_inf_uni
        p12_inf_uni
        p21_inf_uni
        p22_inf_uni

        %The transfer functions
        p11
        p12
        p21
        p22
    end
    
    methods 
        % Initialization with geometric parameters
        function obj = link(shape,data)
            obj.N_in = nan;
            % If we want to construct with only transfer function
            % parameters, call a simple function and exit.
            if shape == '_'
                if iscell(data)
                    data = cell2mat(data);
                end
                obj.Au = data(1);
                obj.tauu = data(2);
                obj.Ad = data(3);
                obj.taud = data(4);
                obj.p11_inf = data(5);
                obj.p12_inf = data(6);
                obj.p21_inf = data(7);
                obj.p22_inf = data(8);
                [obj.p11,obj.p12,obj.p21,obj.p22] = obj.build_tf;
                return;
            end
            
            % The basic quantities, no need for computation
            obj.shape = shape;
            obj.X = data{1};
            obj.n = data{2};
            obj.Sb = data{3};

            Q_arr = data{4};
            obj.Qmax = Q_arr(1);
            obj.Qmin = Q_arr(2);
            obj.Q0 = Q_arr(3);

            obj.YX = data{5};
            obj.Y_up = data{6};

            obj.geo_para = data{7};
            geo_para = data{7};
            if matches(shape,'trapezoid') 
                B = geo_para(1);
                m = geo_para(2);
                obj.A = @(Y) (B*Y+m*Y.^2); 
                obj.T = @(Y) (B+2*m*Y);
                obj.R = @(Y) ((B*Y+m*Y.^2)./(B+2*sqrt(1+m^2)*Y)); 
                obj.P = @(Y) obj.A(Y)./obj.R(Y);
                obj.dPdY = @(Y) 2*sqrt(1+m^2);
                obj.dTdY = @(Y) 2*m;
                obj.manning = @(Y) (1/obj.n)*obj.A(Y).*(obj.R(Y).^(2/3)).*sqrt(obj.Sb);
                obj.dmanning = @(Y) (obj.manning(Y+1e-5)-obj.manning(Y))/(1e-5);
            elseif matches(shape,'circle')
                D = geo_para(1);
                theta = @(Y) 2*acos(1-2*(Y/D));
                obj.A = @(Y) (1/8)*(theta(Y) - sin(theta(Y)));
                obj.T = @(Y) 2*sqrt(Y*(D-Y));
                obj.R = @(Y) (D/4)*(1 - (sin(theta(Y))/theta(Y)));
                obj.P = @(Y) obj.A(Y)./obj.R(Y);
                obj.dPdY = @(Y) (obj.P(Y+1e-5)-obj.P(Y))/(1e-5);
                obj.dTdY = @(Y) (obj.T(Y+1e-5)-obj.T(Y))/(1e-5);
                obj.manning = @(Y) (1/obj.n)*obj.A(Y).*(obj.R(Y).^(2/3)).*sqrt(obj.Sb);
                obj.dmanning = @(Y) (obj.manning(Y+1e-5)-obj.manning(Y))/(1e-5);
            else
                error('Shape can only be trapezoidal or circular.')
            end

            %Sanity Check
            if obj.YX == 0 && obj.Qmax == 0
                error('YX and Qmax cannot both be 0.')
            end

            %The normal depth Yn, computed either from YX or Qmax
            if obj.Y_up == 0
                if obj.YX == 0 %So assign YX = Yn(Qmax)
                    [obj.Yn,obj.YX,obj.N] = obj.get_Yn;
                else  % So we use the YX specified by the user
                    [obj.Yn,~,obj.N] = obj.get_Yn;
                end
            % If user specifies the upstream water depth, set Yn to it
            elseif obj.Y_up ~= 0
                obj.Yn = obj.Y_up;
            end

            %The Backwater Curve Y0(x)
            [obj.Y0,obj.x1,obj.SX] = obj.get_Y0;
            obj.x2 = (obj.x1+obj.X)/2;

            %The Backwater Profile
            [obj.T0,obj.A0,obj.R0,obj.P0,obj.C0,obj.V0,obj.F0,obj.dP0dY,obj.dT0dY,obj.alpha,obj.beta,obj.kappa,obj.gamma,obj.delta] = obj.get_backwater;

            %The low frequency parameters
            [obj.Au,obj.Ad,obj.tauu,obj.taud,obj.Au_uni,obj.Ad_uni,obj.tauu_uni,obj.taud_uni] = obj.get_low;

            %The high frequency parameters
            [obj.p11_inf,obj.p12_inf,obj.p21_inf,obj.p22_inf,obj.p11_inf_uni,obj.p12_inf_uni,obj.p21_inf_uni,obj.p22_inf_uni] = obj.get_high;

            %The resulting transfer functions
            [obj.p11,obj.p12,obj.p21,obj.p22] = obj.build_tf;
        end

        %Initialization with transfer function parameters (Ad,taud,...)
        [Au,tauu,Ad,taud,p11_inf,p12_inf,p21_inf,p22_inf] = link_cons_tf(data)
        
        %Compute the Normal Depth from Qmax
        [Yn_o,YX_o,N] = get_Yn(obj);

        %Compute the Backwater Curve Y0(x)
        [output,x1,SX] = get_Y0(obj);

        %Compute Backwater Profiles
        [T0,A0,R0,P0,C0,V0,F0,dP0dY,dT0dY,alpha,beta,kappa,gamma,delta] = get_backwater(obj)

        %Compute transfer function parameters
        [Au,Ad,tauu,taud,Au_uni,Ad_uni,tauu_uni,taud_uni] = get_low(obj)
        [p11,p12,p21,p22,p11_uni,p12_uni,p21_uni,p22_uni] = get_high(obj)

        %Construct the transfer functions from the parameters above
        [p11,p12,p21,p22] = build_tf(obj)
    end
end

