function TestCaseNoMissedEventsLikelihood
    dc = DataController;
    
    test_params = Test_Setup();
    %test data,concentration and mechanism
    
    lik = Likelihood;
    total_tests=3;
    test_concs=[test_params.conc,0.0000001,0.00001];
    %get Q-matrix representation given the constraints and agonist
    %concentration
    test_names={strcat('[TEST 1] - likelihood calculations at concentration ',test_concs(1)),...
        strcat('[TEST 2] - likelihood calculations at concentration ',test_concs(2)),...
        strcat('[TEST 2] - likelihood calculations at concentration ',test_concs(3))};
        
    diffs=zeros(total_tests,1);
    passed_tests=zeros(total_tests,1);
    
    mech=test_params.mechanism;
    data=test_params.data;
    epsilon = test_params.epsilon;
    
    
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(mech, test_concs(1), data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)
    
    time=tic();
    b_likelihood = lik.basic_hjc_lik(mech, test_concs(1), data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(1),diffs(1)] = TestCompare(b_likelihood,m_likelihood,epsilon);
    
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(mech, test_concs(2), data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)

    time=tic();
    b_likelihood = lik.basic_hjc_lik(mech, test_concs(2), data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(2),diffs(2)] = TestCompare(b_likelihood,m_likelihood,epsilon); 
    
    time=tic();
    m_likelihood = lik.basic_hjc_lik_cpp(mech, test_concs(3), data);
    elapsed=toc(time);
    fprintf('[INFO] - Mex and vectorisation likelihood calculation time = %f\n',elapsed)

    time=tic();
    b_likelihood = lik.basic_hjc_lik(mech, test_concs(3), data);
    elapsed=toc(time);
    fprintf('[INFO] - basic likelihood calculation time = %f\n',elapsed)
    
    [passed_tests(3),diffs(3)] = TestCompare(b_likelihood,m_likelihood,epsilon); 

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