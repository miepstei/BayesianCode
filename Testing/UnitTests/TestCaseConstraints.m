function TestCaseConstraints()

    localpath=getpref('ME','matpath');
    test_params = Test_Setup();
    python_matrices=strcat(test_params.localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/contraints_mr.mat');
    load(python_matrices);
    
    total_tests=7;
    failed_tests=0;
    
    test_names={'[TEST 1]','[TEST 2]',...
        '[TEST 3]','[TEST 4]', ...
        '[TEST 5]','[TEST 6]','[TEST 7]'};
    
    diffs=zeros(total_tests,1);
    mechanism = test_params.mechanism;
    epsilon=test_params.epsilon;
    
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)
    
    mechanism=mechanism.setRates([15.0,15000.0,3000.0,500.0,2000.0,4000.0,1e06,5e08,5e08,0.66667]);
   
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(1,:);
    
    [passed_tests(1),diffs(1)] = TestCompare(pythonRates,testRates,epsilon);
    
    mechanism=mechanism.setRates([100.0,3000.0,10000.0,100.0,1000.0,1000.0,1e07,5e+7,6e+7,10]);
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(2,:);
    
    [passed_tests(2),diffs(2)] = TestCompare(pythonRates,testRates,epsilon);   
    
    fprintf('[TEST 3]\n')
    mechanism=mechanism.setRates([6.5,14800,3640,362,1220,2440,1e+7,5e+8,2.5e+8,55]);
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(3,:);

    [passed_tests(3),diffs(3)] = TestCompare(pythonRates,testRates,epsilon); 
    
    fprintf('[TEST 4]\n')
    mechanism=mechanism.setRates([6.5,14800,3640,362,1220,2440,1e+7,4e+8,2.5e+7,45]);
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(4,:);
    diff=sum(abs(pythonRates(:) - testRates(:)));
    
    [passed_tests(4),diffs(4)] = TestCompare(pythonRates,testRates,epsilon); 
    
    
    fprintf('[TEST 5]\n')
    mechanism=mechanism.setRates([4.5,14800,3640,362,1000,1440,1e+7,5e+8,2.5e+8,55]);   
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(5,:);
    
    [passed_tests(5),diffs(5)] = TestCompare(pythonRates,testRates,epsilon); 
    
    
    %lets test with specific parameter changes
    %change a parameter in the cycle
    mechanism=mechanism.setParameter(4,500);
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(6,:);

    [passed_tests(6),diffs(6)] = TestCompare(pythonRates,testRates,epsilon);
    

    %lets test map functionality specific parameter changes
    %change a parameter in the cycle
    rate_map=containers.Map('KeyType', 'int32','ValueType','any');
    rate_map(1)=16;
    rate_map(3)=6000;
    
    mechanism=mechanism.setParameters(rate_map);
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(7,:);
    [passed_tests(7),diffs(7)] = TestCompare(pythonRates,testRates,epsilon);
    
    
    % *** SUMMARY OF TEST RESULTS ***
    
    passed = sum(passed_tests);
    failed = total_tests-passed;
    
    if sum(passed_tests)==total_tests
        fprintf('[ALL TESTS PASSED] - simplex fittings are the same %d tests passed\n\n',total_tests)
    else
        fprintf('\n\n[FAILED TESTS]\n\n',failed)
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