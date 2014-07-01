classdef ThreeState_4param_AT < ExactIonModel
    %ThreeStateExactIonModel with uniform priors and 
    %overridden metric tensor. %del-Castillo K
       
    methods(Access=public,Static)
        
        function obj = ThreeState_4param_AT()
            obj.kA=1; % 1 open state
            obj.h=0.01;
            obj.k = 4; %4 params
        end
               
        function Q = generateQ(params,conc)
            Q=zeros(3,3);
            
            Q(1,1) = -params(1); 
            Q(1,2) =  params(1); %alpha
            Q(1,3) = 0;
            
            Q(2,1) = params(2); %beta
            Q(2,2) = -(params(2)+params(3)); %-(km1+beta)
            Q(2,3) = params(3); %km1
            
            Q(3,1) = 0;
            Q(3,2) = params(4)*conc; %kp1
            Q(3,3) = -params(4)*conc;
 
        end
        
        function sample = samplePrior()
            %in this model we have two uniform priors
            sample = unifrnd(1e-2,1e10,[obj.k 1]);         
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = sum(log(unifpdf(params,1e-2,1e10)));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(ThreeState_4param_AT.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end        
    end
end