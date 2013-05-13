function mech =Simulations(simNo)
    %2003 generative params
    test_params=Test_Setup('/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_2.mat');
    generativeMec=test_params.mechanism;
    clear test_params

    %generate 20000 intervals
    datasim=generate(generativeMec,1000*60*15,3e-08,20000);
    test_scn=['Testing/TestData/test_',num2str(simNo),'.scn'];
    %resolved=RecordingManipulator.imposeResolution(datasim,0.0025);

    handle=fopen(test_scn,'w','n','UTF-8');
    DataController.write_scn_file(handle,datasim);

    %{
    [~,data]=DataController.read_scn_file(test_scn);
    data.intervals=data.intervals/1000;

    %2003 initial guesses
    test_params=Test_Setup('/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_4.mat');
    test_params.islogspace=true;
    test_params.debugOn=true;

    %write over default data
    test_params.data=data;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;

    lik = ExactLikelihood();
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
    init_params=test_params.mechanism.getParameters(true);
    splx=Simplex();

    a=tic;[min_function_value,min_parameters,~]=splx.run_simplex(lik,init_params,test_params);toc(a);

    test_params.mechanism.toString()
    mech=test_params.mechanism;
    %}

end