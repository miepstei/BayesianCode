function TestCaseNoMissedEventsLikelihood
    
    
    %test data,concentration and mechanism

    
    test_conc = 0.00000001;

    
    total_tests=3;
    
    test_names={'[TEST 1] - likelihood calculations at concentration = 1',...
        '[TEST 2] - likelihood calculations at concentration 2',...
        '[TEST 3] - likelihood calculations at concentration 3'};
    
    diffs=zeros(total_tests,1);
    passed_tests=zeros(total_tests,1);
    
    test_params = Test_Setup();
    epsilon = test_params.epsilon;
    
    %don't want to use bursts for this calculation
    [header,data]=DataController.read_scn_file(strcat(test_params.localpath,'Academic/PhD/Code/bayesiancode/trunk/MarkovModel/Samples/CH82.scn'));
    data.intervals=data.intervals/1000;
        
    %create likelihood object
    lik = Likelihood;
    
    %get Q-matrix representation given the constraints and agonist
    %concentration
    
    fprintf('[TEST 1] - likelihood calculations at concentration = %e\n',test_conc)
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)
    
    time=tic();
    b_likelihood = lik.basic_hjc_lik(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(1),diffs(1)] = TestCompare(m_likelihood,b_likelihood,epsilon); 
         
    test_conc = 0.0000001;
    
    fprintf('[TEST 2] - likelihood calculations at concentration = %e\n',test_conc)
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)

    time=tic();
    b_likelihood = lik.basic_hjc_lik(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(2),diffs(2)] = TestCompare(m_likelihood,b_likelihood,epsilon);    
    
    test_conc = 0.00001;
    
    fprintf('[TEST 3] - likelihood calculations at concentration = %e\n',test_conc)
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)

    time=tic();
    b_likelihood = lik.basic_hjc_lik(test_params.mechanism, test_conc, data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(3),diffs(3)] = TestCompare(m_likelihood,b_likelihood,epsilon);

    % *** SUMMARY OF TEST RESULTS ***
    
    passed = sum(passed_tests);
    failed = total_tests-passed;
    
    if sum(passed_tests)==total_tests
        fprintf('[ALL TESTS PASSED] - simplex fittings are the same %d tests passed\n\n',total_tests)
    else
        fprintf('\n\n[%i FAILED TESTS]\n\n',failed)
        failed_tests = find(passed_tests==0);
        for i=1:length(failed_tests)
            fprintf('\t%s - [DIFF] %f\n',test_names{failed_tests(i)},diffs(failed_tests(i)))
        end  
    end
       
    fprintf('\n\n[ALL TEST DIFFERENCES] - \n\n')
    for i=1:total_tests
        fprintf('\t%s - [DIFF] %f\n',test_names{i},diffs(i))
    end    
    
end