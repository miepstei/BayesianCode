classdef TwoState_2Param_QET < ExactTensorIonModel
    %TwoStateExactIonModel with uniform priors and 
    %overridden metric tensor
       
    methods(Access=public,Static)
        
        function obj = TwoState_2Param_QET(dcp_options)
            obj.kA=1;
            obj.h=0.01;
            obj.k = 2;
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
            Q=zeros(2,2);
            
            Q(1,1) = -params(1); 
            Q(1,2) = params(1); %alpha - open to close
            Q(2,1) = params(2)*conc; %beta - close to open
            Q(2,2) = -params(2)*conc; 
 
        end
        
        function sample = samplePrior()
            %in this model we have two uniform priors
            sample = [unifrnd(1e-2,1e10); unifrnd(1e-2,1e6)];         
        end
        
        function logPrior = calcLogPrior(params)
            if size(params,1) < size(params,2)
                params=params';
            end
            pdf = [unifpdf(params(1),1e-2,1e6); unifpdf(params(2),1e-2,1e10)];
            logPrior = sum(log(pdf));    
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(TwoState_2Param_QET.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end        
    end
end