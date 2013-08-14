function [min_function_value,fittedRates,min_parameters,iterations,rejigs,errors,debug] = fit_simplex( dataFile,paramsFile,mex,newMech,varargin )
    %fit_simplex - a simplex fitting for a mechanism, datafile, params and
    %optional starting rates
    %INPUTS:
    %   datafile: the .scn file to calculate the likelihood for
    %   paramsfile: the set of parameters and mechanism 
    %   varargin: a parameter map (int,double) of starting parameters
    %OUTPUT:
    %   min_function_value: double, negative log likelihood of the best fit
    %   fitted_rates: all fitted rates from the mechanism (inc constrained
    %   min parameters: best fit of the parameters
    %   iterations: number of simplex iterations 
    %   rejigs: number of simplex restarts
    %   errors: number of errors in likelihood evaluation
    %   debug: debug output of simplex
    
    load(paramsFile);
    MSEC_CORRECTION=1000; % needed as scn files are in msec

    [~,data]=DataController.read_scn_file(dataFile);
    data.intervals=data.intervals/MSEC_CORRECTION;

    test_params.mechanism=ModelSetup(paramsFile); 
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.tres = tres; 
    test_params.tcrit = tcrit; %separation of time between bursts  
    test_params.isCHS = 1; %use CHS vectors
    test_params.data = data;
    test_params.conc = concentration;
    test_params.debugOn=1;
    test_params.newMech=newMech;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    if test_params.newMech
        dcprogs_bursts = [bursts.withinburst];
        dcprogs_bursts = {dcprogs_bursts.intervals};
        test_params.bursts=dcprogs_bursts;
    else
        test_params.bursts=bursts;
    end
    burst_length = length(bursts);    
    ave_openings = sum(BurstsAnalyser.fetchNumberOfBurstOpenings(bursts))/burst_length;
    ave_length = MSEC_CORRECTION*sum(BurstsAnalyser.getBurstLengths(bursts))/burst_length;
    
    fprintf('Data Summary\n')
    fprintf('\tNumber of Bursts %i\n',burst_length)
    fprintf('\tAverage Number of Openings %.15f\n',ave_openings)
    fprintf('\tAverage Burst Length %.15f\n',ave_length)    
    
    if length(varargin) == 1
        %then we have some rates to set
        test_params.mechanism.setParameters(varargin{1});       
    end

    if mex
        lik=DCProgsExactLikelihood();
    else
        lik = ExactLikelihood();
        [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
    end
    
    init_params=test_params.mechanism.getParameters(true);
    splx=Simplex();

    a=tic;[min_function_value,min_parameters,iterations,rejigs,errors,debug]=splx.run_simplex(lik,init_params,test_params);toc(a);
    if test_params.islogspace
        min_parameters=containers.Map(min_parameters.keys,cellfun(@exp,min_parameters.values));
    end
    
    test_params.mechanism.setParameters(min_parameters);
    
    test_params.mechanism.toString()
    fittedRates = test_params.mechanism.getParameters(false);


end

