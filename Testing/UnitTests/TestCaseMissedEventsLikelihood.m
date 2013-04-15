function result =  TestCaseMissedEventsLikelihood()
    
    %UNTITLED Test cases for calculating the missed events likelihood
    %   Detailed explanation goes here
    
    %setup
    localpath=getpref('ME','matpath');
    python_matrices=strcat(localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/functions.mat');
    load(python_matrices);
      
    total_tests=7;
    
    test_names={'[TEST 1] - test open f0(t)','[TEST 2] - test open f1(t)','[TEST 3] - test open pdfs eG_AF(t)',...
                '[TEST 4] - test close f0(t)','[TEST 5] - test close f1(t)','[TEST 6] - test close pdfs eG_FA(t)',...
                '[TEST 7] - likeihood on col 82 sample data'};
    
    
    diffs=zeros(total_tests,1);
    passed_tests=zeros(total_tests,1);
    test_params = Test_Setup();
    epsilon = test_params.epsilon;
    
    %test data,concentration and mechanism TO REFACTOR FOR ALL TESTS
    s=-10; % s parameter for Laplace transform functions
    
    %get Q-matrix representation given the constraints and agonist
    %concentration
    Q_rep = test_params.mechanism.setupQ(test_params.conc);
    
    %set up the required likelihood object - we do not need to debug
    %these
    lik = ExactLikelihood();

    t1=tic;
    [lik,setup_time]=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    t1=toc(t1);
    
    
    %lets go
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)
    t=linspace(0.000001, 0.01, 50); %times to calculate the pdf for
    eGAF=zeros(length(t),test_params.mechanism.kA,test_params.mechanism.kE);
    Af0=zeros(length(t),test_params.mechanism.kA,test_params.mechanism.kE);
    Af1=zeros(length(t),test_params.mechanism.kA,test_params.mechanism.kE);
    
    eGFA=zeros(length(t),test_params.mechanism.kE,test_params.mechanism.kA);
    Ff0=zeros(length(t),test_params.mechanism.kE,test_params.mechanism.kA);
    Ff1=zeros(length(t),test_params.mechanism.kE,test_params.mechanism.kA);    
    
    t2=tic;
    for i=1:length(t)
        eGAF(i,:,:) = lik.exact_open_pdf(lik,t(i));
        Af0(i,:,:)=lik.f0(t(i)-lik.tres,lik.eig_valsQ,lik.AZ00);
        Af1(i,:,:)=lik.f1(t(i)-(2*lik.tres),lik.eig_valsQ,lik.AZ10,lik.AZ11);
        
        eGFA(i,:,:) = lik.exact_close_pdf(lik,t(i));
        Ff0(i,:,:)=lik.f0(t(i)-lik.tres,lik.eig_valsQ,lik.FZ00);
        Ff1(i,:,:)=lik.f1(t(i)-(2*lik.tres),lik.eig_valsQ,lik.FZ10,lik.FZ11);
    end
    t2=toc(t2);
   
    [passed_tests(1),diffs(1)] = TestCompare(Af0,p_Af0,epsilon); 

    [passed_tests(2),diffs(2)] = TestCompare(Af1,p_Af1,epsilon); 
    
    [passed_tests(3),diffs(3)] = TestCompare(eGAF,p_eGAF,epsilon);
   
    [passed_tests(4),diffs(4)] = TestCompare(Ff0,p_Ff0,epsilon);
    
    [passed_tests(5),diffs(5)] = TestCompare(Ff1,p_Ff1,epsilon);
     
    [passed_tests(6),diffs(6)] = TestCompare(eGFA,p_eGFA,epsilon);
    
    %lets calcuate a likelihood
    
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    [open shut] = RecordingManipulator.getPeriods(resolvedData);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    
    t3=tic;
    log_likelihood=lik.calculate_likelihood(bursts);
    t3=toc(t3);
    
    [passed_tests(7),diffs(7)] = TestCompare(log_likelihood,p_log_likelihood,epsilon);

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
    
    fprintf('\n\nT\n')
    fprintf('Likelihood setup takes %.2f seconds\n', t1 )
    fprintf('%i Function calculation takes %.2f seconds\n',length(t),t2)
    fprintf('Likelihood calculation takes %.2f seconds\n',t3)
    fprintf('Setup calculations - \n')
    for i=1:length(setup_time.time)
       fprintf('\tSetup %i -> %s took %.4f\n',i,setup_time.names{i},setup_time.time(i)) 
    end
    
end

