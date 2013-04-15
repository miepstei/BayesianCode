function TestCaseSimplex()

    localpath=getpref('ME','matpath');
    python_matrices=strcat(localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/simplex.mat');
    load(python_matrices);
    
    total_tests=10;
    
    test_names={'[TEST 1] - test simplex setup','[TEST 2] - test likelihoods setup',...
        '[TEST 3] - test simplex sort','[TEST 4] - test likelihood sort', ...
        '[TEST 5] - test_simplex_centre','[TEST 6] - test simplex reflect','[TEST 7] - test simplex extend',...
        '[TEST 8] - test simplex contract','[TEST 9] - test simplex shrink' ...
        '[TEST 10] - test end params','[TEST 11] - test end likelihood'};
    diffs=zeros(total_tests,1);
    passed_tests=zeros(total_tests,1);
    
    test_params = Test_Setup();
    epsilon = test_params.epsilon;
    
    
    %setup data
    splx=Simplex();
    lik = ExactLikelihood();
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);  
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;
    test_params.islogspace=true;
    test_params.debugOn=true;
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
 
    init_params=test_params.mechanism.getParameters(true);
    
    
    
    
    [debug,times] = splx.debug_simplex(lik,init_params,test_params);
    
    a=tic;
    [min_function_value,min_parameters,~]=splx.run_simplex(lik,init_params,test_params);
    times.simplex=toc(a);
    
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)
       
    [passed_tests(1),diffs(1)] = TestCompare(debug.setup.simplex_points,p_make_simplex,epsilon); 

    [passed_tests(2),diffs(2)] = TestCompare(debug.setup.function_values,p_make_likelihoods,epsilon); 
       
    [passed_tests(3),diffs(3)] = TestCompare(debug.sorted.simplex_points,p_sorted_simplex,epsilon);             
    
    [passed_tests(4),diffs(4)] = TestCompare(debug.sorted.function_values,p_sorted_likelihoods,epsilon); 
    
    [passed_tests(5),diffs(5)] = TestCompare(debug.reflect.point',p_reflect_point,epsilon);  

    [passed_tests(6),diffs(6)] = TestCompare(debug.extend.point',p_extend_point,epsilon); 
    
    [passed_tests(7),diffs(7)] = TestCompare(debug.contract.point',p_contract_point,epsilon); 
    
    [passed_tests(8),diffs(8)] = TestCompare(debug.shrink.point,p_shrink_simplex,epsilon); 
    
    [passed_tests(9),diffs(9)] = TestCompare(min_function_value,p_function_value,epsilon); 
    
    [passed_tests(10),diffs(10)] = TestCompare(cell2mat(min_parameters.values)',p_min_parameters,epsilon); 
       
    
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

    fprintf('\n\nTIMINGS\n\n')
    
    fprintf('\tSimplex OVERALL %f\n\n', times.simplex)
    fprintf('\tSimplex setup %f\n',times.setup)
    fprintf('\tSimplex matricise %f\n',times.matricise)
    fprintf('\tSimplex sort %f\n',times.sort)
    fprintf('\tSimplex converge %f\n',times.converge)
    fprintf('\tSimplex reflect %f\n',times.reflect)
    fprintf('\tSimplex extend %f\n',times.extend)
    fprintf('\tSimplex contract %f\n',times.contract)
    fprintf('\tSimplex shrink %f\n',times.shrink)
    
    
end

