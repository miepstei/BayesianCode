classdef DCProgsExactLikelihood < Likelihood
    
    methods(Access=public)
        function log_likelihood = evaluate_function(obj,params,function_opts)
            
            %transform the parameters from log space if necessary
            func_params=containers.Map(params.keys,params.values);            
            keySet = params.keys; 
            for i=1:length(keySet)
                if function_opts.islogspace
                    func_params(keySet{i}) = exp(params(keySet{i}));
                else
                    func_params(keySet{i}) = params(keySet{i});
                end
            end
            
            function_opts.mechanism.setParameters(func_params);
            
            
            %bursts need to go into a cell array
            %need raw Q-matrix from mechanism
            %need cell array of burst times - factor this out%

            qmat=function_opts.mechanism.setupQ(function_opts.conc);
            if ~function_opts.newMech
                %interface change for new mech
                qmat=qmat.Q;  
            end
            log_likelihood = -likelihood_mex(function_opts.bursts,qmat,function_opts.tres,function_opts.tcrit,function_opts.mechanism.kA);
    
        end
    end
end