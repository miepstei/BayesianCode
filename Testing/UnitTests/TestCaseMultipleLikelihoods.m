function result = TestCaseMultipleLikelihoods()

    localpath=getpref('ME','matpath');
    python_matrices=strcat(localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/likelihoods.mat');
    
    total_tests=1;
    passed_tests=0;
    failed_tests=0;
    failed_test_names={};
    epsilons=[];
    test_params = Test_Setup();
    lik = ExactLikelihood();
    epsilon=test_params.epsilon;
    
    %set this manually
    epsilon=0.1;
    load(python_matrices);    
    %lets calcuate a likelihood    
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    [open shut] = RecordingManipulator.getPeriods(resolvedData);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);

    
    
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)
    
    for i=1:size(p_sim,1)
       python_likelihood = p_sim(i,1);
       
       rates=p_sim(i,2:end);
       test_params.mechanism=test_params.mechanism.setRates(rates);
       [lik,setup_time]=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
       log_likelihood=lik.calculate_likelihood(bursts);
       %python likelihood is positive
       fprintf('Evaluation %i of %i %f to %f - Diff %f (%f percent)\n',i,size(p_sim,1),log_likelihood,-python_likelihood,abs(log_likelihood+python_likelihood),abs(log_likelihood+python_likelihood)/python_likelihood)
       if abs(log_likelihood+python_likelihood) > epsilon
          fprintf('Diff in %ith likelihood, %f vs %f\n',i,log_likelihood,python_likelihood) 
       end
    end
    



end