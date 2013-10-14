function [ml_param_values,ml_likelihoods,ml_errors,ml_iter,ml_rejigs,ml_hessians,free_parameter_map]=MaximumLikelihood(experiment,calculations,min_rng,max_rng)
    %This script generates a likelihood profile for a given parameter

    %INPUTS:
    %experiment - struct,experimental setup including data, model and params
    %points - the number of ml fittings to run
    %param_no - the parameter with which to run the profile likeihood for
    %min_rng - array - min values of the params in the model
    %max_rng - array - max values of the params in the model
    %param_start_values - a cell array of maps with [points] starting values
    
    %OUTPUTS:
    %param_values - the fitted param profile params (k,points)
    %profile_likelihoods - the fitted param profile likelihoods (points,1)

    
    %we need mix and max limits for each param.
    init_params=experiment.model.getParameters(false);
    parameter_keys = cell2mat(experiment.model.getParameters(true).keys);
    
    %generate some random starting position

    random_start = zeros(calculations,init_params.Count);
    free_parameter_map=cell(calculations,1);
   
    for j=1:length(min_rng)   
        random_start(:,j)=randi([min_rng(j) max_rng(j)],calculations,1);   
    end
    
    for ml_point=1:calculations
        free_parameter_map{ml_point} = containers.Map(int32(parameter_keys),random_start(ml_point,:));
    end
    
    %set up the return matrices
    ml_param_values = zeros(init_params.length(),calculations);
    ml_likelihoods = zeros(calculations,1);
    ml_errors = zeros(calculations,1);
    ml_iter = zeros(calculations,1);
    ml_rejigs = zeros(calculations,1);
    ml_hessians = zeros(calculations,length(min_rng),length(min_rng));
       
    for ml_calc=1:calculations
        %set rates on mechanism, specified from param_start_values typically either from random starting
        %positions or from constant rates
        
        start_values = free_parameter_map{ml_calc} ;
        experiment.model.setParameters(start_values);
               
        try
            fprintf('ML calculation %i\n', ml_calc);
            fit = fit_experiment(experiment);
            ml_likelihoods(ml_calc)=fit.likelihood;
            ml_errors(ml_calc) = fit.errors;
            ml_iter(ml_calc) = fit.iterations;
            ml_rejigs(ml_calc)=fit.rejigs;
            ml_param_values(:,ml_calc) = cell2mat(fit.parameters.values)';
            ml_hessians(ml_calc,:,:) = fit.hessian;
        catch MExc
            fprintf('Fitting failed for %i failed (%s)\n', ml_calc,MExc.message);
            fprintf(experiment.model.toString());
            fprintf('\nmoving on to next fitting...\n')
            ml_likelihoods(ml_calc)=NaN;
            ml_param_values(:,ml_calc) = NaN;
            ml_errors(ml_calc) = NaN;
            ml_iter(ml_calc) = NaN;
            ml_rejigs(ml_calc)=NaN; 
            ml_hessians(ml_calc,:,:) = NaN;
        end
    end
    
    %restore inital parameters
    experiment.model.setParameters(init_params);
 end