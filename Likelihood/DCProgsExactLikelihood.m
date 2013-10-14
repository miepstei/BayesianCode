classdef DCProgsExactLikelihood < Likelihood
    
    methods(Access=public)
        
        
        function [log_likelihood,error] = calculate_likelihood(obj,experiment)      
            
            log_likelihood = 0;
            for i = 1:length(experiment.parameters.concs)
                qmat=experiment.model.setupQ(experiment.parameters.concs(i));
                if ~experiment.parameters.newMech
                    %interface change for new mech
                    qmat=qmat.Q;  
                end
                [likelihood , error] = likelihood_mex(experiment.data{i},qmat,experiment.parameters.tres(i),experiment.parameters.tcrit(i),experiment.model.kA);
                if error == 1
                    log_likelihood = 0;
                    break;
                else
                    log_likelihood = log_likelihood-likelihood;
                end
            end
        end
        
        function [log_likelihood,return_params,error] = evaluate_function(obj,params,function_opts)
            
            %transform the parameters from log space if necessary
            func_params=containers.Map(params.keys,params.values);            
            keySet = params.keys; 
            for i=1:length(keySet)
                if function_opts.parameters.fit_logspace
                    func_params(keySet{i}) = exp(params(keySet{i}));
                else
                    func_params(keySet{i}) = params(keySet{i});
                end
            end
            
            function_opts.model.setParameters(func_params);
            
            
            %bursts need to go into a cell array
            %need raw Q-matrix from mechanism
            %need cell array of burst times - factor this out%
            log_likelihood = 0;
            for i = 1:length(function_opts.parameters.concs)
                qmat=function_opts.model.setupQ(function_opts.parameters.concs(i));
                if ~function_opts.parameters.newMech
                    %interface change for new mech
                    qmat=qmat.Q;  
                end
                [likelihood, error] = likelihood_mex(function_opts.data{i},qmat,function_opts.parameters.tres(i),function_opts.parameters.tcrit(i),function_opts.model.kA);
                if error == 1
                    log_likelihood = 0;
                    break;
                else
                    log_likelihood = log_likelihood-likelihood;
                end                  
            end
            
            %the proposed parameters might have hit limits in the mechanism
            %so return what is actually on the new mechanism as the simplex
            %values 
            if function_opts.parameters.fit_logspace
                return_params=function_opts.model.getParameters(1);
            else
                return_params=function_opts.model.getParameters(0);
            end
        end
    end
end