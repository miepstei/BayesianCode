function fit = fit_experiment(experiment)
    %This fits a model with given data and experimental conditions
    
    %INPUTS - experiment, a struct containing the model, data and
    %experimental parameters
    
    %OUTPUTS - struct - the mechanism with the fitted parameters
    %                 - maximum log-likelihood
    %                 - number of simplex iterations
    %                 - number of "shuffles" necessary as the likelihood becomes uncalculatable
    %                 - number of function errors
    %                 - debug info, if requested
    %                 - the hessian of the ML fit, by finite-difference
    

    lik=DCProgsExactLikelihood();   
    splx=Simplex();
    tic;
    [min_function_value,min_parameters,iterations,rejigs,errors,debug_info]=splx.run_simplex(lik,experiment.model.getParameters(true),experiment);
    toc;
    %transfform the parameters back to real space 
    if experiment.parameters.fit_logspace
        min_parameters=containers.Map(min_parameters.keys,cellfun(@exp,min_parameters.values));
    end
    
    %set the final parameters on the model
    experiment.model.setParameters(min_parameters);
    
    fit.parameters = experiment.model.getParameters(false);
    fit.likelihood = min_function_value;
    fit.iterations = iterations;
    fit.rejigs = rejigs;
    fit.errors = errors;
    if experiment.parameters.debug_on
        fit.debug = debug_info;
    end
    %fit.hessian = calc_hessian(experiment);
    if experiment.parameters.calc_hessian
        fit.hessian = hessian(@(x) move_Q_hessian(x,experiment),cell2mat(experiment.model.getParameters(0).values));
    end
end