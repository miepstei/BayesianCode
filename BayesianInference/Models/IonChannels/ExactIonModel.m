classdef (Abstract)ExactIonModel < BayesianModel
    %UNTITLED Abstract Bayesian Model for Ion-channels with exact missed
    %events likelihood calculation
    %   All concrete subclasses must implement Q matrix generation and
    %   specify priors
    
    properties(GetAccess = 'public', SetAccess = 'public')
        h  %finite difference stepsize
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        kA %number of open states
    end
    
    methods(Abstract,Static) 
        Q = generateQ(params,conc) %matrix, k * k, contruct the Q-matrix which represents the model
    end
    
    methods(Access=public)
        
    
        function logLik = calcLogLikelihood(obj,params,data)
            
            %CALCLOGLIKELIHOOD - calculate the DCPROGS log-likeihood of an
            %ion-channel model given parameters and data
            %
            % OUTPUTS
            %       logLik - scalar, the log-likelihood
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function
            
            
            logLik = 0;
            for experimentSet = 1:length(data.concs)
                bursts = data.bursts{experimentSet};
                concentration = data.concs(experimentSet);
                tres = data.tres(experimentSet);
                tcrit = data.tcrit(experimentSet);
                useChs = data.useChs(experimentSet);
                qmat=obj.generateQ(params,concentration);
                try
                    [likelihood , error] = likelihood_mex(bursts,qmat,tres,tcrit,obj.kA,useChs);
                    if error == 1
                        logLik=-Inf;
                        break
                    else
                        logLik = logLik+likelihood;
                    end
                catch 
                    logLik=-Inf;
                    break                    
                end
            end
        end
        
        function logPosterior = calcLogPosterior(obj,params,data)
            %CALCLOGPOSTERIOR - calculate the log-posterior of an
            %ion-channel model given parameters and data
            %
            % OUTPUTS
            %       logPosterior - scalar, the log-posterior
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function
            prior = obj.calcLogPrior(params);
            if prior==-Inf
                logPosterior=-Inf;
            else
                logPosterior = obj.calcLogLikelihood(params,data) + obj.calcLogPrior(params);
            end
        end
        
        function gradLogLikelihood = calcGradLogLikelihood(obj,params,data)
            %CALCGRADLOGLIKELIHOOD - calculate the first order gradients of 
            % log-likelihood of an ion-channel model given parameters and
            % data. Method uses finite-differences
            %
            % OUTPUTS
            %       gradLogLikelihood - k*1 vector, gradients
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function 
            
            gradLogLikelihood = zeros(obj.k,1);
            for i=1:obj.k;
               currentParamValue = params(i);
               
               %f(x+h)
               params(i)=currentParamValue+obj.h;
               fp = obj.calcLogLikelihood(params,data);
               
               %f(x-h)
               params(i)=currentParamValue-obj.h;
               fm = obj.calcLogLikelihood(params,data);
               
               gradLogLikelihood(i) = (fp-fm)/(2*obj.h);
               
               %reset param value 
               params(i)= currentParamValue;
            end  
        end
        
        function gradLogPosterior = calcGradLogPosterior(obj,params,data)
            %CALCGRADLOGPOSTERIOR - calculate the first order gradients of 
            % log-posterior of an ion-channel model given parameters and
            % data. Method uses finite-differences
            %
            % OUTPUTS
            %       gradLogPosterior - k*1 vector, gradients
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function
            
            gradLogPosterior = obj.calcGradLogLikelihood(params,data) + obj.calcDerivLogPrior(params);
        end
        
        function metricTensor = calcMetricTensor(obj,params,data)
            %CALCMETRICTENSOR - calculate the second order derivatives of 
            % log-posterior of an ion-channel model given parameters and
            % data. Method uses second order finite-differences. Stepsize
            % is specified at object construction
            %
            % OUTPUTS
            %       metricTensor - k*k matrix, second order derivs
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function
            
            metricTensor = zeros(obj.k,obj.k);
            
            for i=1:obj.k
                for j=i:obj.k
                    if (i==j)
                        % 3 likelihood calculations
                        currentParamValue = params(i);
                        fc = obj.calcLogLikelihood(params,data);
                        
                        params(i) = currentParamValue+obj.h;
                        fp = obj.calcLogLikelihood(params,data);
                        
                        params(i) = currentParamValue-obj.h;
                        fm = obj.calcLogLikelihood(params,data);
                        
                        metricTensor(i,j) = (fp-(2*fc)+fm)/(obj.h^2);
                        params(i) = currentParamValue;
                    else
                        %off diagonal elements have 4 likelihood calcs
                        currentParamValue1=params(i);
                        currentParamValue2=params(j);
                        
                        %pp
                        params(i) = currentParamValue1+obj.h;
                        params(j) = currentParamValue2+obj.h;
                        fpp = obj.calcLogLikelihood(params,data);
                        
                        %pm
                        params(i) = currentParamValue1+obj.h;
                        params(j) = currentParamValue2-obj.h;
                        fpm = obj.calcLogLikelihood(params,data);
                        
                        %mp
                        params(i) = currentParamValue1-obj.h;
                        params(j) = currentParamValue2+obj.h;
                        fmp = obj.calcLogLikelihood(params,data);
                        
                        %mm                        
                        params(i) = currentParamValue1-obj.h;
                        params(j) = currentParamValue2-obj.h;
                        fmm = obj.calcLogLikelihood(params,data);
                        
                        %observed information matrix
                        metricTensor(i,j) = (fmm+fpp-fpm-fmp)/(4*obj.h^2);
                        
                        params(i)=currentParamValue1;
                        params(j)=currentParamValue2;
                    end
                end
            end
            %symmetric matrix so copy over the triangular components
            metricTensor = -(metricTensor + triu(metricTensor,1)');
            
        end
        
        function derivMetricTensor = calcDerivMetricTensor(obj,~,~)
            %DERIVMETRICTENSOR - calculate the derivatives second order derivatives of 
            % log-posterior of an ion-channel model given parameters and
            % data. UNIMPLEMENTED, method returns zeros
            %
            % OUTPUTS
            %       derivMetricTensor - k*k matrix of zeros
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function            
            derivMetricTensor = zeros(obj.k,obj.k);
        end
  
    end
    
end

