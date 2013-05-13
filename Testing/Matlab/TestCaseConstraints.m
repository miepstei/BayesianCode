function TestCaseConstraints(paramsFile,verbose)

    test_params = Test_Setup(paramsFile);
    load(test_params.mrInFile);
    
    total_tests=1;
    failed_tests=0;
       
    test_names={'[TEST 1] - Testing contraints and MR'};
    
    diffs=zeros(total_tests,1);
    mechanism = test_params.mechanism;
    epsilon=test_params.epsilon;
    mechanism=mechanism.updateConstrainedRates();
    rates = mechanism.getRates();
    testRates=rates(:,2)';
    pythonRates=p_withconstraints(1,:);
    
    [passed_tests(1),diffs(1)] = TestCompare(pythonRates,testRates,epsilon);
    

    
    if verbose
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
    
    save(test_params.mrOutFile,'passed_tests','diffs','test_names','testRates','pythonRates');
    
end