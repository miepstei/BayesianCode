function TestCaseBursts(paramsFile,verbose)
    MSEC_CORRECTION = 1000; %for comparable to dc-pyps
    
    test_params = Test_Setup(paramsFile);
    load(test_params.burstsInFile);
    total_tests=8; %tcrit and tres
    test_names={'[TEST 1] - t_res burst number', '[TEST 2] - t_crit burst number ',...
        '[TEST 3] - t_res resolved number number', '[TEST 4] - t_crit resolved number', ...
        '[TEST 5] - t_res ave openings per burst ', '[TEST 6] - t_crit ave openings per burst ', ...
        '[TEST 7] - t_res avg length', '[TEST 8] - t_crit average length'};

    passed_tests=zeros(total_tests,1);
    diffs=zeros(total_tests,1);
    
    tcrit_test_no = length(test_params.testTcrit);
    tres_test_no = length(test_params.testTres);
    
    tres_tests = zeros(tres_test_no,1);
    tres_resolved = zeros(tres_test_no,1);
    tres_ave_length = zeros(tres_test_no,1);
    tres_ave_openings = zeros(tres_test_no,1);
    
    tcrit_tests = zeros(tcrit_test_no,1);
    tcrit_resolved = zeros(tcrit_test_no,1);
    tcrit_ave_length = zeros(tcrit_test_no,1);
    tcrit_ave_openings = zeros(tcrit_test_no,1);
    
    data=test_params.data;
    test_params.tcrit = test_params.testTcrit(1);
    for i=1:length(tres_tests)
        %preprocess data and apply resolution
        
        test_params.tres = test_params.testTres(i);
        resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
        tres_resolved(i) = length(resolvedData.intervals);
        
        bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
        tres_tests(i) = length(bursts);
        
        tres_ave_openings(i) = sum(BurstsAnalyser.fetchNumberOfBurstOpenings(bursts))/tres_tests(i);
        
        tres_ave_length(i) = MSEC_CORRECTION*sum(BurstsAnalyser.getBurstLengths(bursts))/tres_tests(i);
        
    end
    
    %reset tres to first value. resolved data is now invariant
    test_params.tres = test_params.testTres(1);
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);

    for i=1:length(test_params.testTcrit)
        tcrit_resolved(i) = length(resolvedData.intervals);
        test_params.tcrit = test_params.testTcrit(i);
        
        bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
        tcrit_tests(i) = length(bursts);
        
        tcrit_ave_openings(i) = sum(BurstsAnalyser.fetchNumberOfBurstOpenings(bursts))/tcrit_tests(i);
        
        tcrit_ave_length(i) = MSEC_CORRECTION*sum(BurstsAnalyser.getBurstLengths(bursts))/tcrit_tests(i);
    end
    
    [passed_tests(1),diffs(1)] = TestCompare(tres_tests,p_tres_tests,test_params.epsilon);
    [passed_tests(2),diffs(2)] = TestCompare(tcrit_tests,p_tcrit_tests,test_params.epsilon);
    [passed_tests(3),diffs(3)] = TestCompare(tres_resolved,p_tres_resolved,test_params.epsilon);
    [passed_tests(4),diffs(4)] = TestCompare(tcrit_resolved,p_tcrit_resolved,test_params.epsilon);
    [passed_tests(5),diffs(5)] = TestCompare(tres_ave_openings,p_tres_ave_openings,test_params.epsilon);
    [passed_tests(6),diffs(6)] = TestCompare(tcrit_ave_openings,p_tcrit_ave_openings,test_params.epsilon);
    [passed_tests(7),diffs(7)] = TestCompare(tres_ave_length,p_tres_ave_length,test_params.epsilon);
    [passed_tests(8),diffs(8)] = TestCompare(tcrit_ave_length,p_tcrit_ave_length,test_params.epsilon);

   

    if verbose
    
        % *** SUMMARY OF TEST RESULTS ***

        passed = sum(passed_tests);
        failed = total_tests-passed;

        if sum(passed_tests)==total_tests
        fprintf('[ALL TESTS PASSED] - Burst calculations are the same %d tests passed\n\n',total_tests)
        else
        fprintf('\n\n [%i FAILED TESTS]\n\n',failed)
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
    save(test_params.burstsOutFile, 'tcrit_tests','tres_tests','test_names','passed_tests','diffs');
end