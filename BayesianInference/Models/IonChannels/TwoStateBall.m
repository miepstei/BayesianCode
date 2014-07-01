classdef TwoStateBall < BayesianModel
    %TWOSTATEAPPROXIMATEIONMODEL Two State Ion-Model implementing
    %approximate likelihood of Ball 1990 "Single-Channel Data and Missed
    %Events: Analysis of a Two State Markov Model"
    %   Used to reporduce the bi-modality int he above paper, overrides the
    %   exact likelihood method of Colquhoun (1996)

    properties(GetAccess = 'public', SetAccess = 'public')
        h  %finite difference stepsize
    end
        
    methods(Access=public,Static)
        
        function obj = TwoStateBall()
            obj.h=0.01;
            obj.k = 2;
        end
        
        function Q = generateQ(params,conc)
            Q=zeros(2,2);
            
            Q(1,1) = -params(1); %alpha - open to close
            Q(1,2) = params(1);
            Q(2,1) = params(2)*conc;
            Q(2,2) = -params(2)*conc; %beta - close to open
 
        end        
        
        function logLik = calcLogLikelihood(params,data)
           
            %CALCLOGLIKELIHOOD - calculate the approximate log-likeihood of an
            %ion-channel model given parameters and data
            %
            % OUTPUTS
            %       logLik - scalar, the log-likelihood
            %
            % INPUTS 
            %       params - k*1 vector, parameter values
            %       data - struct, understood by the likelihood function 
            
            logLik=0;
            intervals=0;
            for experimentSet = 1:length(data.concs)
                bursts = data.bursts{experimentSet};
                concentration = data.concs(experimentSet);
                tres = data.tres(experimentSet);
                %tcrit = data.tcrit(experimentSet);

                %[likelihood , error] = likelihood_mex(bursts,qmat,tres,tcrit,obj.kA,useChs);
                likelihood_set = 0;
                
                %don't need to worry about opening vectors
                %mu_c=1/params(1); %closed to open
                %mu_o=1/params(2); %open to closed
                
                mu_o=params(1); %open to closed - alpha
                mu_c=params(2); %closed to open - beta
                
                alpha = mu_o*exp((concentration*tres)/mu_c);
                beta = (mu_c/concentration)*exp(tres/mu_o);
                
                
                for i=1:length(bursts)
                    burst_lik=0;
                    burst = bursts{i};
                    for j=1:length(burst)
                        intervals=intervals+1;
                        if mod(j,2) == 0
                            %its a closed interval
                            burst_lik= burst_lik+log((beta^-1)*exp(-burst(j)/beta));
                        else
                            burst_lik = burst_lik+log((alpha^-1)*exp(-burst(j)/alpha));
                        end
                    end
                    likelihood_set=likelihood_set+burst_lik;
                end
                logLik = logLik+(likelihood_set*(1/intervals));
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
            logPosterior = obj.calcLogLikelihood(params,data) + obj.calcLogPrior(params);
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
  
            
        
        function sample = samplePrior()
            %in this model we have two uniform priors
            sample = unifrnd(1e-2,10e6,[2 1]);         
        end
        
        function logPrior = calcLogPrior(params)
            logPrior = sum(log(unifpdf(params,1e-2,1e6)));   
        end
        
        function derivLogPrior = calcDerivLogPrior(params)
            if isinf(TwoStateExactIonModel.calcLogPrior(params))
                derivLogPrior = -Inf;
            else
                derivLogPrior = 0;
            end   
        end
    end
    
end

