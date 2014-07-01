classdef NuclearPumpModel < BayesianModel
    %Taken from Robert and Casalla (2004)
    properties(Constant)
        BETA_INDEX=1; %index of the beta parameter in the params array
        ALPHA=1.8;
        GAMMA=0.01;
        DELTA=1;
    end    
    
    methods(Access=public,Static)

        function obj = NuclearPumpModel()
            obj.k = 11; 
        end
        
        function logLikelihood = calcLogLikelihood(params,data)
            
            logLikelihood=0;
            for i=1:length(data)
                logLikelihood=logLikelihood+log(params(NuclearPumpModel.BETA_INDEX+i)^data(i,1)) -(params(NuclearPumpModel.BETA_INDEX+i)*data(i,2));
            end
        end
        
        function logPosterior = calcLogPosterior(params,data)
            %form of data 
            % data(i,1) = number of failures
            % data(i,2) = over time period
            
            
            betas = log(params(NuclearPumpModel.BETA_INDEX)^17.01*exp(-params(NuclearPumpModel.BETA_INDEX)));
            poisson=0;
            for i=1:length(data)
                a=params(i+NuclearPumpModel.BETA_INDEX)^(data(i,1)+0.8);
                b=exp((-params(i+1)*(data(i,2)+params(1))));
                poisson=poisson+log(a)+log(b);
            end
            logPosterior=betas+poisson;
        end
        
        function gradLogLikelihood = calcGradLogLikelihood(params,data)
           
            gradLogLikelihood = zeros(11,1);
            gradLogLikelihood(1) = 0;
            for i=1:10
                gradLogLikelihood(i+NuclearPumpModel.BETA_INDEX) = data(i,1)/(params(i+NuclearPumpModel.BETA_INDEX)) - data(i,2);
            end           
           
        end
        
        function gradLogPosterior = calcGradLogPosterior(params,data)
            gradLogPosterior = NuclearPumpModel.calcGradLogLikelihood(params,data) + NuclearPumpModel.calcDerivLogPrior(params);
        end
        
        function metricTensor = calcMetricTensor(params,data)
            %IGNORE
            metricTensor=zeros(11,11);
        end
        
        function derivMetricTensor = calcDerivMetricTensor(~,~)
            %IGNORE
            derivMetricTensor = zeros(11,11);
        end
        

        
        function sample = samplePrior()
            %IGNORE
            sample=zeros(11,1);
        end
        
        function logPrior = calcLogPrior(params)
            
            logPrior=0;
            if(any(params<0))
                logPrior=-Inf;
            else
                for i=1:10
                    logPrior=logPrior+log(params(i+NuclearPumpModel.BETA_INDEX)^(NuclearPumpModel.ALPHA-1)*exp(-params(1)*params(i+NuclearPumpModel.BETA_INDEX)));
                end
                logPrior=logPrior+log(params(NuclearPumpModel.BETA_INDEX))*(NuclearPumpModel.GAMMA-1+(10*NuclearPumpModel.ALPHA))-(NuclearPumpModel.DELTA*params(NuclearPumpModel.BETA_INDEX));
        
            end
        end
        function derivLogPrior = calcDerivLogPrior(params)  
            derivLogPrior=zeros(11,1);
            derivLogPrior(1) = sum(-params((NuclearPumpModel.BETA_INDEX+1):end)) + (10*NuclearPumpModel.ALPHA/params(NuclearPumpModel.BETA_INDEX))+(NuclearPumpModel.GAMMA-1)/params(NuclearPumpModel.BETA_INDEX) - NuclearPumpModel.DELTA;
            for i=1:10
                derivLogPrior(i+NuclearPumpModel.BETA_INDEX) = (NuclearPumpModel.ALPHA-1)/params(i+NuclearPumpModel.BETA_INDEX) - params(NuclearPumpModel.BETA_INDEX);
            end
            
        end        
    end    
    
    
end