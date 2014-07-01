classdef FiveState_9param_QET < ExactTensorIonModel
    %TwoStateExactIonModel with uniform priors and 
    %overridden metric tensor
       
    methods(Access=public,Static)
        
        function obj = FiveState_9param_QET()
            obj.kA=2; % 2 open states
            obj.h=0.01;
            obj.k = 5; %9 params
        end
               
        function Q = generateQ(params,conc)
            Q=zeros(5,5);
            
            %param array defined as follows
            %in 1985 model, params(1) = params(7);params(5)=params(8)
            
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
            %in this model we have two uniform priors
            sample = unifrnd(1e-2,1e10,[obj.k 1]);         
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = sum(log(unifpdf(params,1e-2,1e10)));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(FiveState_9param_QET.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end        
    end
end