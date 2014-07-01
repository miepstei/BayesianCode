classdef TwoState_2param_QET < ExactTensorIonModel
    %TwoStateExactIonModel with uniform priors and 
    %overridden metric tensor
       
    methods(Access=public,Static)
        
        function obj = TwoState_2param_QET()
            obj.kA=1;
            obj.h=0.01;
            obj.k = 2;
        end
               
        function Q = generateQ(params,conc)
            Q=zeros(2,2);
            
            Q(1,1) = -params(1); 
            Q(1,2) = params(1); %alpha - open to close
            Q(2,1) = params(2)*conc; %beta - close to open
            Q(2,2) = -params(2)*conc; 
 
        end
        
        function sample = samplePrior()
            %in this model we have two uniform priors
            sample = unifrnd(1e-2,1e10,[2 1]);         
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = sum(log(unifpdf(params,1e-2,1e10)));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(TwoState_2param_QET.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end        
    end
end