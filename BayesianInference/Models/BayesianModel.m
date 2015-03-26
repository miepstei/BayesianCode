classdef BayesianModel
    %UNTITLED Abstact class defining functions to be implemented by model
    %   Forms the basis for an ion-channel model
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        k % the number of parameters in the model
    end
    
    properties(Constant)
        LogPost = 1
        GradLogPost = 2
        MetricTensor = 3
        DerivMetTensor = 4
    end
    
    methods(Abstract,Static)
        logPrior = calcLogPrior(params) %scalar, log-likelihood of prior | params
        derivLogPrior = calcDerivLogPrior(params) %scalar, deriv of log-likelihood of prior | params      
        sample = samplePrior()  % k * 1 vector sampled from the prior distribution      
    end
    
    methods(Abstract)
        logLik = calcLogLikelihood(obj,params,data) %scalar, log-likelihood of data | params
        logPosterior = calcLogPosterior(obj,params,data) %scalar, log-posterior of data | params
        gradLogLikelihood = calcGradLogLikelihood(obj,params,data) %k*1 vector, first order deriv of log-likelihood
        gradLogPosterior = calcGradLogPosterior(obj,params,data) %k*1 vector, first order deriv of log-posterior
        metricTensor = calcMetricTensor(obj,params,data) %k*k second order derivs of log-posterior
        derivMetricTensor = calcDerivMetricTensor(obj,params,data) %k*k derivs of metric tensor
    end
    
    methods
        %implementation; may be overridden
        function information = calcGradInformation(obj,params,data,requiredInfo)
            
            if requiredInfo(BayesianModel.LogPost) == 1
                information.LogPosterior=obj.calcLogPosterior(params,data);
            else
                information.LogPosterior=NaN;
            end
            
            if requiredInfo(BayesianModel.GradLogPost) == 1 && information.LogPosterior ~= -Inf
                information.GradLogPosterior=obj.calcGradLogPosterior(params,data);
            else
                information.GradLogPosterior=NaN(obj.k,1);
            end
            
            if requiredInfo(BayesianModel.MetricTensor) == 1 && information.LogPosterior ~= -Inf
                information.MetricTensor=obj.calcMetricTensor(params,data);
            else
                information.MetricTensor=NaN(obj.k,obj.k);
            end
            
            if requiredInfo(BayesianModel.DerivMetTensor) == 1 && information.LogPosterior ~= -Inf
                information.DerivMetricTensor=obj.calcDerivMetricTensor(params,data);
            else
                information.DerivMetricTensor=NaN(obj.k,obj.k,obj.k);
            end
                           
        end %wrapper for gradient information to allow more efficient implementation        
    end
end

