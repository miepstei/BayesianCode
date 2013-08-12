function TestCaseExactLikelihood(paramsFile,verbose)
   
    test_params = Test_Setup(paramsFile);
    load(test_params.likelihoodsInFile);
    test_params.mechanism=test_params.mechanism.updateConstrainedRates();
    test_names={'[TEST 1] - calculate likelihood'};
    total_tests=1;
    
    diffs=zeros(total_tests,1);
    passed_tests=zeros(total_tests,1);

    
    lik = ExactLikelihood();
    epsilon=test_params.epsilon;

    %lets calcuate a likelihood    
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
   
    
    python_likelihood = p_sim;   
    [lik,setup_time]=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    log_likelihood=lik.calculate_likelihood(bursts);
    %python likelihood is positive
    
    [passed_tests(1),diffs(1)] = TestCompare(python_likelihood,log_likelihood,epsilon); 
    
    if verbose
        if sum(passed_tests)==total_tests
            fprintf('[ALL TESTS PASSED] - Maximum likelihoods %f are the same %d tests passed\n\n',log_likelihood,total_tests)
        else
            fprintf('\n\n[%i FAILED TESTS]\n\n',total_tests-sum(passed_tests))
            fprintf('Likelihoods - MATLAB %f PYTHON %f',log_likelihood,p_sim)
            failed_tests = find(passed_tests==0);
            for i=1:length(failed_tests)
                fprintf('\t%s - [DIFF] %f\n',test_names{failed_tests(i)},diffs(failed_tests(i)))
            end  
        end
    end



end