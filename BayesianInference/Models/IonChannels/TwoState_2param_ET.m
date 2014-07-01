classdef TwoState_2param_ET < TwoState_2param_AT
    %TwoStateExactIonModel with uniform priors and 
    %overridden metric tensor
    
    properties

    end
    
    methods(Access=public)
        
        function obj = TwoState_2param_ET()
            obj.kA=1;
            obj.h=0.01;
            obj.k = 2;
        end
        
        function metricTensor = calcMetricTensor(obj,params,data)
            %CALCMETRICTENSOR - calculate the second order derivatives of 
            % log-posterior of an ion-channel model given parameters and
            % data. Method uses 3d PARTY second order finite-differences.
            %
            % OUTPUTS
            %       metricTensor - k*k matrix, second order derivs
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function
            
            metricTensor = -hessian(@(x) obj.calcLogPosterior(x,data),params);
            
        end
    end
end