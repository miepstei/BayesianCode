function TestCaseExactLikelihoodSetup()

    localpath=getpref('ME','matpath');
    test_params = Test_Setup();
    
    python_matrices=strcat(test_params.localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/matrices.mat');
    load(python_matrices);
    
    
    test_names={'[TEST 1] - -Q matrix spectral expansion','[TEST 2] - Q matrix',...
        '[TEST 3] - QAA matrix','[TEST 4] - QFF matrix', ...
        '[TEST 5] - spectral expansion of QAA matrix','[TEST 6] - expAA matrix calculations','[TEST 7] - expFF matrix calculations',...
        '[TEST 8] - G_AF matrix calculations','[TEST 9] - G_FA matrix calculations' ...
        '[TEST 10] - eG_AF matrix calculations','[TEST 11] - eG_FA matrix calculations' ...
        '[TEST 12] - phiA matrix calculations','[TEST 13] - phiF matrix calculations',...
        '[TEST 14] - AC00 matrix calculations','[TEST 15] - AC10 matrix calculations',...
        '[TEST 16] - AC11 matrix calculations','[TEST 17] - AZ00 matrix calculations',...
        '[TEST 18] - AZ10 matrix calculations','[TEST 19] - AZ11 matrix calculations',...
        '[TEST 20] - FC00 matrix calculations','[TEST 21] - FC10 matrix calculations',...
        '[TEST 22] - FC11 matrix calculations','[TEST 23] - FZ00 matrix calculations',...
        '[TEST 24] - FZ10 matrix calculations','[TEST 25] - FZ11 matrix calculations',...
        '[TEST 26] - test start CHS vector','[TEST 27] - test end CHS vector'};
    
    
    total_tests=27;
    passed_tests=zeros(total_tests,1);
    diffs=zeros(total_tests,1);    
    
    
    
    load(python_matrices);
    load(strcat(test_params.localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/asymptotic.mat'));
    
    %create likelihood object
    lik = ExactLikelihood();
    
    
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)
    
    %get Q-matrix representation given the constraints and agonist
    %concentration
    Q_rep = test_params.mechanism.setupQ(test_params.conc);
    epsilon=test_params.epsilon;
    lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    
    [specQ,~,~] = lik.spectral_expansion(-Q_rep.Q);
    
    
    [passed_tests(1),diffs(1)] = TestCompare(specQ,p_specQ,epsilon);   
    
    time=tic();
    matrices=lik.likelihood_debug();
    elapsed=toc(time);
    fprintf('[INFO] - Exact likelihood matricies calculation time = %f\n',elapsed)
    
    [passed_tests(2),diffs(2)] = TestCompare(matrices.Q,p_Q,epsilon);
    
    [passed_tests(3),diffs(3)] = TestCompare(matrices.Q_AA,p_QAA,epsilon);
       
    [passed_tests(4),diffs(4)] = TestCompare(matrices.Q_FF,p_QFF,epsilon);
    
    [passed_tests(5),diffs(5)] = TestCompare(matrices.specA,p_specA,epsilon);
       
    [passed_tests(6),diffs(6)] = TestCompare(matrices.expAA,p_expQAA,epsilon);
    
    [passed_tests(7),diffs(7)] = TestCompare(matrices.expFF,p_expQFF,epsilon);
    
    [passed_tests(8),diffs(8)] = TestCompare(matrices.G_AF,p_GAF,epsilon);
    
    [passed_tests(9),diffs(9)] = TestCompare(matrices.G_FA,p_GFA,epsilon);
    
    [passed_tests(10),diffs(10)] = TestCompare(matrices.eG_AF,p_eGAF,epsilon);
              
    [passed_tests(11),diffs(11)] = TestCompare(matrices.eG_FA,p_eGFA,epsilon);
    
    [passed_tests(12),diffs(12)] = TestCompare(matrices.phiA,p_phiA,epsilon);
    
    [passed_tests(13),diffs(13)] = TestCompare(matrices.phiF,p_phiF,epsilon);
    
    [passed_tests(14),diffs(14)] = TestCompare(matrices.open_Z_constants.AC00,p_AC00,epsilon);
    
    [passed_tests(15),diffs(15)] = TestCompare(matrices.open_Z_constants.AC10,p_AC10,epsilon);
    
    [passed_tests(16),diffs(16)] = TestCompare(matrices.open_Z_constants.AC11,p_AC11,epsilon);
    
    [passed_tests(17),diffs(17)] = TestCompare(matrices.open_Z_constants.AZ00,p_AZ00,epsilon);
    
    [passed_tests(18),diffs(18)] = TestCompare(matrices.open_Z_constants.AZ10,p_AZ10,epsilon);
    
    [passed_tests(19),diffs(19)] = TestCompare(matrices.open_Z_constants.AZ11,p_AZ11,epsilon);
    
    [passed_tests(20),diffs(20)] = TestCompare(matrices.close_Z_constants.FC00,p_FC00,epsilon);
    
    [passed_tests(21),diffs(21)] = TestCompare(matrices.close_Z_constants.FC10,p_FC10,epsilon);
    
    [passed_tests(22),diffs(22)] = TestCompare(matrices.close_Z_constants.FC11,p_FC11,epsilon);
    
    [passed_tests(23),diffs(23)] = TestCompare(matrices.close_Z_constants.FZ00,p_FZ00,epsilon); 
    
    [passed_tests(24),diffs(24)] = TestCompare(matrices.close_Z_constants.FZ10,p_FZ10,epsilon); 
    
    [passed_tests(25),diffs(25)] = TestCompare(matrices.close_Z_constants.FZ11,p_FZ11,epsilon);
    
    [passed_tests(26),diffs(26)] = TestCompare(matrices.beginCHS',p_start,epsilon);
    
    [passed_tests(27),diffs(27)] = TestCompare(matrices.endCHS,p_finish,epsilon);
    
    
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