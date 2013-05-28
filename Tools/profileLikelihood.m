function [param_values,profile_likelihoods]=profileLikelihood(dataFile,paramsFile,points,param_no,min,max)
    %dataFile - scn file containing the recording
    %paramsFile - file containing which mechanism to use and initial
    %parameter values
    %points  - the number of points in which to sample the min-max param
    %param_no - the key with which to run the profile likeihood for

    load(paramsFile);
    [~,data]=DataController.read_scn_file(dataFile);
    data.intervals=data.intervals/1000;

    test_params.mechanism=ModelSetup(paramsFile);
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.tres = tres; 
    test_params.tcrit = tcrit; %separation of time between bursts  
    test_params.isCHS = 1; % use CHS vectors
    test_params.data = data;
    test_params.conc = concentration;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;

    lik = ExactLikelihood();
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
    init_params=test_params.mechanism.getParameters(true);
    
    %param_keys = keys(init_params);

    
    
    %we need mix and max limits for each param. Need to treat the param as
    %fixed to generate the profile likelihood
    
    rate = test_params.mechanism.rates(param_no);
    constraint=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',param_no,'args',1);
    test_params.mechanism.setConstraint(param_no,constraint);
    
    init_params=test_params.mechanism.getParameters(true);
    param_values = zeros(init_params.length()+1,points);
    profile_likelihoods = zeros(1,points);
    
    %calculate exponential schedule between min and max containing
    %points

    profile_rates=exp(linspace(log(min),log(max),points));
    splx=Simplex();
    for p_rate=1:length(profile_rates)
        %set rate on mechanism  
        %this code starts the next profile point from the previous guess. Reason is to
        %reduce the problem of finding another local max likelihood if
        %applicable
        
        test_params.mechanism.setRate(param_no,profile_rates(p_rate),true);
        start_params = test_params.mechanism.getParameters(true);
        try
            fprintf('Fitting for profile point %i Rate name %s value %f\n', p_rate,rate.name,profile_rates(p_rate));
            [min_function_value,min_parameters,~]=splx.run_simplex(lik,start_params,test_params);
            profile_likelihoods(p_rate)=min_function_value;
            param_values(1,p_rate) = log(profile_rates(p_rate));
            param_values(2:end,p_rate)=cell2mat(min_parameters.values);
        catch MExc
            fprintf('Fitting for profile point %i (%d) failed (%s)\n', p_rate,profile_rates(p_rate),MExc.message);
            fprintf(test_params.mechanism.toString());
            fprintf('\nmoving on...\n')
            profile_likelihoods(p_rate)=NaN;
            param_values(1,p_rate) = profile_rates(p_rate);
            param_values(2:end,p_rate)=NaN;
            %need to restart fit from 'init params'
            test_params.mechanism.setParameters(init_params);
        end

    end
        
        

end