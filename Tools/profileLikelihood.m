function [param_values,profile_likelihoods,profile_errors,profile_iter,profile_rejigs]=profileLikelihood(dataFile,paramsFile,points,param_no,min_rng,max_rng,param_start_values)
    
    %INPUTS:
    %dataFile - scn file containing the recording
    %paramsFile - file containing which mechanism to use and initial
    %points  - the number of points in which to sample the min-max param
    %param_no - the key with which to run the profile likeihood for
    %min_rng - min value of the parameter from which to start the profile
    %max_rng - max value of the parameter from which to start the profile
    %param_start_values - a cell array of maps with starting values
    
    %OUTPUTS:
    %param_values - the fitted param profile params (k,points)
    %profile_likelihoods - the fitted param profile likelihoods (points,1)

    load(paramsFile);
    [~,data]=DataController.read_scn_file(dataFile);
    data.intervals=data.intervals/1000;

    test_params.mechanism=ModelSetup(paramsFile);
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.tres = tres; 
    test_params.tcrit = tcrit;  
    test_params.isCHS = 1; 
    test_params.data = data;
    test_params.conc = concentration;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;

    lik = ExactLikelihood();
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
       
    %we need mix and max limits for each param. Need to treat the param as
    %fixed to generate the profile likelihood
    
    %fix the parameter to be profiled as a constraint
    rate = test_params.mechanism.rates(param_no);
    constraint=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',param_no,'args',1);
    test_params.mechanism.setConstraint(param_no,constraint);
    
    %set up the return matrices
    init_params=test_params.mechanism.getParameters(true);
    param_values = zeros(init_params.length()+1,points);
    profile_likelihoods = zeros(points,1);
    profile_errors = zeros(points,1);
    profile_iter = zeros(points,1);
    profile_rejigs = zeros(points,1);
      
    %calculate exp schedule between min and max containing points
    profile_rates=exp(linspace(log(min_rng),log(max_rng),points));
    
    splx=Simplex();
    for p_rate=1:length(profile_rates)
        %set rates on mechanism, specified from param_start_values typically either from random starting
        %positions or from constant rates
        
        start_values = param_start_values{p_rate} ;
        test_params.mechanism.setParameters(start_values);
        
        %fit the profile rate and get the new start parameters after
        %applying constraints
        test_params.mechanism.setRate(param_no,profile_rates(p_rate),true);
        start_params = test_params.mechanism.getParameters(true);
        
        try
            fprintf('Fitting for profile point %i Rate name %s value %f\n', p_rate,rate.name,profile_rates(p_rate));
            [min_function_value,min_parameters,iter,rejigs,errors,~]=splx.run_simplex(lik,start_params,test_params);
            profile_likelihoods(p_rate)=min_function_value;
            profile_errors(p_rate) = errors;
            profile_iter(p_rate) = iter;
            profile_rejigs(p_rate)=rejigs;
            param_values(1,p_rate) = log(profile_rates(p_rate));
            param_values(2:end,p_rate)=cell2mat(min_parameters.values);
        catch MExc
            fprintf('Fitting for profile point %i (%d) failed (%s)\n', p_rate,profile_rates(p_rate),MExc.message);
            fprintf(test_params.mechanism.toString());
            fprintf('\nmoving on...\n')
            profile_likelihoods(p_rate)=NaN;
            param_values(1,p_rate) = profile_rates(p_rate);
            param_values(2:end,p_rate)=NaN;
            profile_errors(p_rate) = NaN;
            profile_iter(p_rate) = NaN;
            profile_rejigs(p_rate)=NaN;            
            

        end

    end
        
 end