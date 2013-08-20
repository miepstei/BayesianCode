function [param_values,profile_likelihoods,profile_errors,profile_iter,profile_rejigs,free_parameter_map]=profileLikelihood(experiment,points,param_no,min_rng,max_rng)
    %This script generates a likelihood profile for a given parameter

    %INPUTS:
    %experiment - struct,experimental setup including data, model and params
    %points - the number of points in the profile likelihood
    %param_no - the parameter with which to run the profile likeihood for
    %min_rng - array - min values of the params in the model
    %max_rng - array - max values of the params in the model
    %param_start_values - a cell array of maps with [points] starting values
    
    %OUTPUTS:
    %param_values - the fitted param profile params (k,points)
    %profile_likelihoods - the fitted param profile likelihoods (points,1)

    %we need mix and max limits for each param. Need to treat the param as
    %fixed to generate the profile likelihood
    ratename = experiment.model.rates(param_no).name;
    
    %fix the parameter to be profiled as a constraint in the model
    experiment.model.setConstraint(param_no,param_no,1);

    %generate some random starting position
    init_params=experiment.model.getParameters(true);
    parameter_keys = cell2mat(init_params.keys);
    random_start = zeros(points,init_params.Count);
    free_parameter_map=cell(points,1);
    
    %find the indices and values of all other free params into the range
    %arrays
    range_param_idx=find(parameter_keys~=param_no);
   
    for j=1:length(range_param_idx)   
        random_start(:,j)=randi([min_rng(range_param_idx(j)) max_rng(range_param_idx(j))],points,1);   
    end
    for profile_point=1:points
        free_parameter_map{profile_point} = containers.Map(int32(parameter_keys),random_start(profile_point,:));
    end
    
    %set up the return matrices
    param_values = zeros(init_params.length()+1,points);
    profile_likelihoods = zeros(points,1);
    profile_errors = zeros(points,1);
    profile_iter = zeros(points,1);
    profile_rejigs = zeros(points,1);
    

      
    %calculate exp schedule between min and max containing points
    profile_rates=exp(linspace(log(min_rng(param_no)),log(max_rng(param_no)),points));
    
    for p_rate=1:length(profile_rates)
        %set rates on mechanism, specified from param_start_values typically either from random starting
        %positions or from constant rates
        
        start_values = free_parameter_map{p_rate} ;
        experiment.model.setParameters(start_values);
        experiment.model.setRates(containers.Map(param_no,profile_rates(p_rate)));
               
        try
            fprintf('Fitting for profile point %i Rate name %s value %f\n', p_rate,ratename,profile_rates(p_rate));
            fit = fit_experiment(experiment);
            profile_likelihoods(p_rate)=fit.likelihood;
            profile_errors(p_rate) = fit.errors;
            profile_iter(p_rate) = fit.iterations;
            profile_rejigs(p_rate)=fit.rejigs;
            param_values(1,p_rate) = log(profile_rates(p_rate));
            param_values(2:end,p_rate)=cell2mat(fit.parameters.values)';
        catch MExc
            fprintf('Fitting for profile point %i (%d) failed (%s)\n', p_rate,profile_rates(p_rate),MExc.message);
            fprintf(experiment.model.toString());
            fprintf('\nmoving on to next point...\n')
            profile_likelihoods(p_rate)=NaN;
            param_values(1,p_rate) = profile_rates(p_rate);
            param_values(2:end,p_rate)=NaN;
            profile_errors(p_rate) = NaN;
            profile_iter(p_rate) = NaN;
            profile_rejigs(p_rate)=NaN;            
        end

    end
        
 end