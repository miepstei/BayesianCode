classdef LogisticRegressionModel < BayesianModel
    %LOGISTIC REGRESSION MODEL - a credit model used in 'Riemann manifold Langevin and Hamiltonian Monte Carlo methods' in
    % JRSSB March 2011. Used for testing samplers with geometric and
    % non-geometric proposals
    
    properties(Constant)
        %sd of the hyperparameter
        SIGMA=100;
    end
    
    methods(Access=public) 
        
    	function obj = LogisticRegressionModel()
            obj.k = 15;
        end
    
    end
    methods(Access=public,Static)
        
        function logLikelihood = calcLogLikelihood(params,data)
            %log likelihood for logistic regression (XB)'Y - sum(log(1+exp(XB)))
            betaX=(data.explanatory)*params;
            logLikelihood = betaX'*data.response - sum(log(1+exp(betaX)));
        end
        
        function logPosterior = calcLogPosterior(params,data)
            logPosterior = LogisticRegressionModel.calcLogLikelihood(params,data) + LogisticRegressionModel.calcLogPrior(params);
        end
        
        function gradLogLikelihood = calcGradLogLikelihood(params,data)
           %Score of the log likelihood for logistic regression
           betaX = data.explanatory*params;
           gradLogLikelihood = data.explanatory' * (data.response-exp(betaX)./(1+exp(betaX)));
        end
        
        function gradLogPosterior = calcGradLogPosterior(params,data)
            gradLogPosterior = LogisticRegressionModel.calcGradLogLikelihood(params,data) + LogisticRegressionModel.calcDerivLogPrior(params);
        end
        
        function metricTensor = calcMetricTensor(params,data)
            %expected Fisher Information for logistic regression model
            betaX = data.explanatory*params;
            p = 1./(1+exp(-betaX));
            v = p.*(1-p);
            metricTensor=zeros(size(data.explanatory,1),size(data.explanatory,2));
            for j = 1:size(data.explanatory,2)   
                 metricTensor(:,j) = data.explanatory(:,j).*v;
            end
            metricTensor = (metricTensor'*data.explanatory) + (eye(size(data.explanatory,2),size(data.explanatory,2))*(1/LogisticRegressionModel.SIGMA));
            
        end
        
        function derivMetricTensor = calcDerivMetricTensor(~,~)
            %ignored for this model
            derivMetricTensor = zeros(2,2);
        end
        
        function sample = samplePrior()
            sample=normrnd(zeros(1,length(params)),repmat(LogisticRegressionModel.SIGMA,1,length(params)));
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = log(mvnpdf(params',zeros(1,length(params)),repmat(LogisticRegressionModel.SIGMA,1,length(params))));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            derivLogPrior = -(params./LogisticRegressionModel.SIGMA);
        end        
    end
    
    
end
