classdef (Abstract)ExactTensorIonModel < ExactIonModel
    %ExactTensorIonModel Abstract Bayesian Model for Ion-channels with exact missed
    %events likelihood calculation. Uses a more sophisticated finite-difference
    %calculation for first-order and second order derivatives
    
    properties(Constant)
        stepRatio = 2.0000001;
        rombergTerms = 2;
        maxStep=0.5;
        deltaTerms=25;
    end
       
    methods(Access=public)
        
        
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

            delta = ExactTensorIonModel.maxStep*ExactTensorIonModel.stepRatio .^(0:-1:-ExactTensorIonModel.deltaTerms)';
            ndeltas = length(delta);     
            
            %first order variables
            fdarule2 = 1;
            nfda2=length(fdarule2);
            ne2 = ndeltas + 1 - length(fdarule2) - ExactTensorIonModel.rombergTerms;            
            fMethodOrder=2;
            fRombexpon = 2*(1:ExactTensorIonModel.rombergTerms) + fMethodOrder - 2;

            %minimum step sizes for all parameters
            nominalSteps = max(params , 0.02);

            %function evaluations below/above x for all parameters
            [f_minusdel,f_plusdel] = obj.funcEvaluations(params,data,delta,nominalSteps,1); 

            %evaluate the sensitvities for each parameter
            for m=1:length(params)
                %parameter specific variables to be used

                nominalSteps(m)=nominalSteps(m);

                %first order diagonal derivatives
                f_del_deriv = (f_plusdel(:,m) - f_minusdel(:,m))/2;

                der_init_derivs = v2m(f_del_deriv,ne2,nfda2)*fdarule2.';
                der_init_derivs = der_init_derivs(:)./(nominalSteps(m)*delta(1:ne2));

                [der_romb_deriv,errors] = rxt(ExactTensorIonModel.stepRatio,der_init_derivs,fRombexpon);

                nest = length(der_romb_deriv);
                trim = [1 2 nest-1 nest];
                [der_romb_deriv,tags] = sort(der_romb_deriv);
                der_romb_deriv(trim) = [];
                tags(trim) = [];
                errors = errors(tags);
                [~,ind] = min(errors);

                %results
                gradLogLikelihood(m) = der_romb_deriv(ind);                
            end
        end        
        
        
        function [f_minus,f_plus] = funcEvaluations(obj,params,data,delta,nominalSteps,likelihood)
            %function evaluations below/above x
            noParams = max(size(params));
            noEvals=length(delta);
            
            f_minus = zeros(noEvals,noParams);
            f_plus = zeros(noEvals,noParams);          

            basis = repmat(params',noEvals,1);
            if likelihood
                func = @(x)obj.calcLogLikelihood(x,data);
            else
                func = @(x)obj.calcLogPosterior(x,data);
            end
            for m=1:noParams
                upperParamDeltas=basis;
                lowerParamDeltas=basis;
                upperParamDeltas(:,m) = upperParamDeltas(:,m)+(delta*nominalSteps(m));
                lowerParamDeltas(:,m) = lowerParamDeltas(:,m)-(delta*nominalSteps(m));               
                parfor k=1:length(delta)                  
                    f_plus(k,m)=func(upperParamDeltas(k,:));
                    f_minus(k,m)=func(lowerParamDeltas(k,:));
                end
            end
        end
        
        %1st order gradient information can be reused so best to calculate all
        %in one go
        function information = calcGradInformation(obj,params,data,requiredInfo)
            
            if sum(requiredInfo(3:4)) == 0
                
                if requiredInfo(BayesianModel.LogPost) == 1
                    information.LogPosterior=obj.calcLogPosterior(params,data);
                else
                    information.LogPosterior=NaN;
                end
                
                if requiredInfo(BayesianModel.GradLogPost) == 1
                    information.GradLogPosterior=obj.calcGradLogPosterior(params,data);
                else
                    information.GradLogPosterior=NaN(obj.k,1);
                end                
                
                information.MetricTensor=NaN(obj.k,obj.k);
                information.DerivMetricTensor=NaN(obj.k,obj.k,obj.k);
                
            else
                %we need the accurate first order information for caluclate
                %the second order info so calculate that along the way
                if requiredInfo(BayesianModel.MetricTensor) == 1
                    
                    %setup matrices
                    gradLogPosterior = zeros(obj.k,1);
                    metricTensor=zeros(obj.k,obj.k);
                    hessianDiagonals=zeros(obj.k,1);
                    order_1_steps= zeros(obj.k,1);

                    delta = ExactTensorIonModel.maxStep*ExactTensorIonModel.stepRatio .^(0:-1:-ExactTensorIonModel.deltaTerms)';
                    ndeltas = length(delta);           

                    %evaluate function at current params
                    f_x=obj.calcLogPosterior(params,data);

                    %hessian  variables
                    hMethodOrder=4;
                    hDerivativeOrder=2;

                    srinv = 1./ExactTensorIonModel.stepRatio;
                    nterms=2;
                    [i,j] = ndgrid(1:nterms);
                    c = 1./factorial(2:2:(2*nterms));
                    mat = c(j).*srinv.^((i-1).*(2*j));
                    fdarule = [1 0]/mat;
                    nfda = length(fdarule); 
                    ne = ndeltas + 1 - nfda - ExactTensorIonModel.rombergTerms;
                    hRombexpon = 2*(1:ExactTensorIonModel.rombergTerms) + hMethodOrder - 2;


                    %first order variables
                    %[n,o] = ndgrid(1:nterms);
                    %c = 1./factorial(1:2:(2*nterms));
                    fdarule2 = 1;
                    nfda2=length(fdarule2);
                    ne2 = ndeltas + 1 - length(fdarule2) - ExactTensorIonModel.rombergTerms;            
                    fMethodOrder=2;
                    fRombexpon = 2*(1:ExactTensorIonModel.rombergTerms) + fMethodOrder - 2;

                    %minimum step sizes for all parameters
                    nominalSteps = max(params , 0.02);

                    %function evaluations below/above x for all parameters
                    [f_minusdel,f_plusdel] = obj.funcEvaluations(params,data,delta,nominalSteps,0); 

                    %evaluate the sensitvities for each parameter
                    for m=1:length(params)
                        %parameter specific variables to be used
                        %x=params(m);
                        %nominalStep = max(x , 0.02);
                        %h=nominalStep;  
                        nominalSteps(m)=nominalSteps(m);

                        %first order diagonal derivatives
                        f_del_deriv = (f_plusdel(:,m) - f_minusdel(:,m))/2;

                        der_init_derivs = v2m(f_del_deriv,ne2,nfda2)*fdarule2.';
                        der_init_derivs = der_init_derivs(:)./(nominalSteps(m)*delta(1:ne2));

                        [der_romb_deriv,errors] = rxt(ExactTensorIonModel.stepRatio,der_init_derivs,fRombexpon);

                        nest = length(der_romb_deriv);
                        trim = [1 2 nest-1 nest];
                        [der_romb_deriv,tags] = sort(der_romb_deriv);
                        der_romb_deriv(trim) = [];
                        tags(trim) = [];
                        errors = errors(tags);
                        trimdelta = delta(tags);
                        [~,ind] = min(errors);
                        finaldelta = nominalSteps(m)*trimdelta(ind);

                        %results
                        gradLogPosterior(m) = der_romb_deriv(ind);                
                        order_1_steps(m) = finaldelta;


                        %hessian diagonal derivatives
                        f_del = (f_plusdel(:,m) + f_minusdel(:,m))/2 - f_x;

                        % Form the initial derivative estimates from the chosen
                        % finite difference method.
                        der_init = v2m(f_del,ne,nfda)*fdarule.';
                        der_init = der_init(:)./(nominalSteps(m)*delta(1:ne)).^hDerivativeOrder;
                        [der_romb,errors] = rxt(ExactTensorIonModel.stepRatio,der_init,hRombexpon);
                        nest = length(der_romb);
                        trim = [1 2 nest-1 nest];
                        [der_romb,tags] = sort(der_romb);
                        der_romb(trim) = [];
                        tags(trim) = [];
                        errors = errors(tags);
                        %trimdelta = delta(tags);
                        [~,ind] = min(errors);
                        %finaldelta = nominalSteps(m)*trimdelta(ind);
                        hessianDiagonals(m) = der_romb(ind);
                    end

                    metricTensor(logical(eye(size(metricTensor)))) = hessianDiagonals;
                    % Get params.RombergTerms+1 estimates of the upper
                    % triangle of the hessian matrix
                    rbt=3;
                    dfac = ExactTensorIonModel.stepRatio.^(-(0:rbt)');
                    for j = 2:obj.k
                        for i = 1:(j-1)
                            dij = zeros(rbt+1,1);
                            for k = 1:(rbt+1)
                                %off diagonal elements have 4 likelihood calcs
                                currentParamValue1=params(i);
                                currentParamValue2=params(j);

                                %pp
                                params(i) = currentParamValue1+dfac(k)*order_1_steps(i);
                                params(j) = currentParamValue2+dfac(k)*order_1_steps(j);
                                fpp = obj.calcLogPosterior(params,data);

                                %pm
                                params(i) = currentParamValue1+dfac(k)*order_1_steps(i);
                                params(j) = currentParamValue2-dfac(k)*order_1_steps(j);
                                fpm = obj.calcLogPosterior(params,data);

                                %mp
                                params(i) = currentParamValue1-dfac(k)*order_1_steps(i);
                                params(j) = currentParamValue2+dfac(k)*order_1_steps(j);
                                fmp = obj.calcLogPosterior(params,data);

                                %mm                        
                                params(i) = currentParamValue1-dfac(k)*order_1_steps(i);
                                params(j) = currentParamValue2-dfac(k)*order_1_steps(j);
                                fmm = obj.calcLogPosterior(params,data);

                                params(i)=currentParamValue1;
                                params(j)=currentParamValue2;
                                %observed information matrix
                                dij(k) = (fmm+fpp-fpm-fmp);

                            end
                            dij = dij/4/prod(order_1_steps([i,j]));
                            dij = dij./(dfac.^2);    
                            % Romberg extrapolation step
                            [metricTensor(i,j),~] =  rxt(ExactTensorIonModel.stepRatio,dij,[2 4]);
                            metricTensor(j,i) = metricTensor(i,j);    
                        end
                    end
                    
                    information.MetricTensor=-metricTensor;
                    information.GradLogPosterior = gradLogPosterior;
                    information.LogPosterior=f_x;
                else
                    information.MetricTensor=NaN(obj.k,obj.k);
                end    
                
                if requiredInfo(BayesianModel.DerivMetTensor) == 1
                    %unimplemented
                    information.DerivMetricTensor=obj.calcDerivMetricTensor(params,data);
                else
                    information.DerivMetricTensor=NaN(obj.k,obj.k,obj.k);
                end                
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
            information = obj.calcGradInformation(params,data,[1,1,1,0]);
            metricTensor = information.MetricTensor;
        end
    end  
end

