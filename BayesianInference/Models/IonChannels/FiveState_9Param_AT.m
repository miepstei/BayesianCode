classdef FiveState_9Param_AT < ExactIonModel
    %TwoStateExactIonModel with uniform priors and 
    %overridden metric tensor
       
    methods(Access=public,Static)
        
        function obj = FiveState_9Param_AT(dcp_options)
            obj.kA=2; % 2 open states
            obj.h=0.01;
            obj.k = 9; %9 params
            if nargin == 1
                obj.options = dcp_options;
            else
                obj.options{1}=2;
                obj.options{2}=1e-12;
                obj.options{3}=1e-12;
                obj.options{4}=100;
                obj.options{5}=-1e6;
                obj.options{6}=0;
            end
        end
               
        function Q = generateQ(params,conc)
            Q=zeros(5,5);
 
            %States numbered regularly in this mechanism:

            %      1 - 2
            %      |   |
            %  5 - 4 - 3
            
            
            %param array defined as follows
            %params(1) = kp_2*
            %params(2) = alpha_1
            %params(3) = alpha_2
            %params(4) = Beta_2
            %params(5) = km_2
            %params(6) = Beta_1
            %params(7) = kp_2
            %params(8) = km_1
            %params(9) = kp_1
            
            Q(1,1) = -(params(1)*conc + params(2)); 
            Q(1,2) = params(1)*conc; %kp2* 
            Q(1,3) = 0;
            Q(1,4) = params(2); %alpha1
            Q(1,5) = 0;
            
            Q(2,1) = 2*(params(1)*params(3)*params(5)*params(6))/(params(2)*params(7)*params(4)); %km2* set by mr 
            Q(2,2) = -(Q(2,1) + params(3)); 
            Q(2,3) = params(3); %alpha2 
            Q(2,4) = 0;
            Q(2,5) = 0;
            
            Q(3,1) = 0;
            Q(3,2) = params(4); %beta2 
            Q(3,3) = -(params(4) + 2*params(5));
            Q(3,4) = 2*params(5); %km2
            Q(3,5) = 0;

            Q(4,1) = params(6); %beta1
            Q(4,2) = 0; 
            Q(4,3) = params(7)*conc; %kp2
            Q(4,4) = -(params(6) + params(7)*conc+params(8));
            Q(4,5) = params(8); %km1

            Q(5,1) = 0;
            Q(5,2) = 0; 
            Q(5,3) = 0;
            Q(5,4) = 2*params(9)*conc; %kp1
            Q(5,5) = -2*params(9)*conc;            
        end
        
        function sample = samplePrior()
            sample = [unifrnd(1e-2,1e10,[1 1]); unifrnd(1e-2,1e6,[5 1]); unifrnd(1e-2,1e10,[1 1]); unifrnd(1e-2,1e6); unifrnd(1e-2,1e10)];         
        end
        
        function logPrior = calcLogPrior(params)
            if size(params,1) < size(params,2)
                params=params';
            end
            pdf = [unifpdf(params(1),1e-2,1e10); unifpdf(params(2:6),1e-2,1e6); unifpdf(params(7),1e-2,1e10); unifpdf(params(8),1e-2,1e6);unifpdf(params(9),1e-2,1e10)];
            logPrior = sum(log(pdf));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(FiveState_9Param_QET.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end        
    end
end