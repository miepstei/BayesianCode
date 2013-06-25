function [min_function_value,fittedRates,min_parameters] = fit_simplex( dataFile,paramsFile,varargin )
%fit_simplex Summary of this function goes here
%   Detailed explanation goes here

    load(paramsFile);

    [~,data]=DataController.read_scn_file(dataFile);
    data.intervals=data.intervals/1000;

    test_params.mechanism=ModelSetup(paramsFile); %'/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_4.mat');
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.tres = tres; 
    test_params.tcrit = tcrit; %separation of time between bursts  
    test_params.isCHS = 1; % use CHS vectors
    test_params.data = data;
    test_params.conc = concentration;
    test_params.debugOn=1;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;
    
    if length(varargin) == 1
        %we have some rates to set
        test_params.mechanism.setParameters(varargin{1});
        
    end

    lik = ExactLikelihood();
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
    init_params=test_params.mechanism.getParameters(true);
    splx=Simplex();

    a=tic;[min_function_value,min_parameters,debug]=splx.run_simplex(lik,init_params,test_params);toc(a);

    test_params.mechanism.toString()
    fittedRates = test_params.mechanism.getRates();


end

