classdef NormalModel < BayesianModel
    %NORMAL MODEL Simple 1-D Gaussian Model
    %   For testing purposes, used in Ben Calderhead's thesis 2011
    %   Implements the basic features of a model required for geometric
    %   MCMC
    
    properties(Constant)
        MU_LOWER=-20;
        MU_HIGHER=20;
        
        SIGMA_LOWER=0;
        SIGMA_HIGHER=100;
    end
    
    methods(Access=public,Static)
        
        function logLikelihood = calcLogLikelihood(params,data)
            logLikelihood = sum(log(normpdf(data,params(1),params(2))));
        end
        
        function logPosterior = calcLogPosterior(params,data)
            logPosterior =  NormalModel.calcLogLikelihood(params,data) + NormalModel.calcLogPrior(params);
        end
        
        function gradLogLikelihood = calcGradLogLikelihood(params,data)
           %Score of the log likelihood for normal dist
           gradLogLikelihood = zeros(2,1);
           N=length(data);
           gradLogLikelihood(1) = (1/params(2)^2)*sum((data-params(1)));
           gradLogLikelihood(2) = -(N/(params(2))) + ((1/(params(2)^3))*sum((data-params(1)).^2));
        end
        
        function gradLogPosterior = calcGradLogPosterior(params,data)
            gradLogPosterior = NormalModel.calcGradLogLikelihood(params,data) + NormalModel.calcDerivLogPrior(params);
        end
        
        function metricTensor = calcMetricTensor(params,data)
            %expected Fisher Information for univ Normal
            metricTensor=zeros(2,2);
            metricTensor(1,1)=(length(data)/(params(2)^2));
            metricTensor(1,2)= 0;
            metricTensor(2,1)= 0;
            metricTensor(2,2)= (2*length(data)/(params(2)^2));
        end
        
        function derivMetricTensor = calcDerivMetricTensor(~,~)
            derivMetricTensor = zeros(2,2);
        end
        
        function obj = NormalModel()
            obj.k = 2; 
        end
        
        function sample = samplePrior()
            %in this model we have two uniform priors for mean and variance
            sample=zeros(2,1);
            sample(1) = unifrnd(NormalModel.MU_LOWER,NormalModel.MU_HIGHER);
            sample(2) = unifrnd(NormalModel.SIGMA_LOWER,NormalModel.SIGMA_HIGHER);
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = log(unifpdf(params(1),NormalModel.MU_LOWER,NormalModel.MU_HIGHER)) + log(unifpdf(params(2),NormalModel.SIGMA_LOWER,NormalModel.SIGMA_HIGHER));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            derivLogPrior=zeros(2,1);
            if isinf(log(unifpdf(params(1),NormalModel.MU_LOWER,NormalModel.MU_HIGHER)))
                derivLogPrior(1) = -Inf;
            else
                derivLogPrior(1) = 0;
            end
            
            if isinf(log(unifpdf(params(2),NormalModel.SIGMA_LOWER,NormalModel.SIGMA_HIGHER)))
                derivLogPrior(2) = -Inf;
            else
                derivLogPrior(2) = 0;
            end            
            
            
        end        
    end
    
end

