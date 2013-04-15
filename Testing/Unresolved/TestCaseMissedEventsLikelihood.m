function result =  TestCaseMissedEventsLikelihood()
    
    %UNTITLED Test cases for calculating the missed events likelihood
    %   Detailed explanation goes here
    
    %setup
    localpath=getpref('ME','matpath');
    python_matrices=strcat(localpath,'Academic/PhD/Code/dc-pyps/me_tests/test_data/functions.mat');
    
    total_tests=7;
    passed_tests=0;
    failed_tests=0;
    failed_test_names={};
    epsilons=[];
    
    %test data,concentration and mechanism TO REFACTOR FOR ALL TESTS
    test_params = Test_Setup();
    s=-10; % s parameter for Laplace transform functions
    
    %get Q-matrix representation given the constraints and agonist
    %concentration
    Q_rep = test_params.mechanism.setupQ(test_params.conc);
    load(python_matrices);
    
    %set up the required likelihood object - we do not need to debug
    %these
    lik = ExactLikelihood();
    epsilon=test_params.epsilon;
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
        eGAF(i,:,:) = lik.exact_open_pdf(t(i));
        Af0(i,:,:)=lik.f0(t(i)-lik.tres,lik.eig_valsQ,lik.AZ00);
        Af1(i,:,:)=lik.f1(t(i)-(2*lik.tres),lik.eig_valsQ,lik.AZ10,lik.AZ11);
        
        eGFA(i,:,:) = lik.exact_close_pdf(t(i));
        Ff0(i,:,:)=lik.f0(t(i)-lik.tres,lik.eig_valsQ,lik.FZ00);
        Ff1(i,:,:)=lik.f1(t(i)-(2*lik.tres),lik.eig_valsQ,lik.FZ10,lik.FZ11);
    end
    t2=toc(t2);
    
    
    
    
    fprintf('[TEST 1] - test open f0(t)\n')

    diff=sum(abs(Af0(:) - p_Af0(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(Af0), size(p_Af0)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='open f0(t)';
        epsilons(failed_tests)=diff;
    end 

    fprintf('[TEST 2] - test open f1(t)\n')
    diff=sum(abs(Af1(:) - p_Af1(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(Af1), size(p_Af1)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='open f1(t)';
        epsilons(failed_tests)=diff;
    end
   
    
    fprintf('[TEST 3] - test open pdfs eG_AF(t)\n')
    diff=sum(abs(Af1(:) - p_Af1(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(eGAF), size(p_eGAF)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='eGAF(t)';
        epsilons(failed_tests)=diff;
    end

    fprintf('[TEST 4] - test close f0(t)\n')

    diff=sum(abs(Ff0(:) - p_Ff0(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(Ff0), size(p_Ff0)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='close f0(t)';
        epsilons(failed_tests)=diff;
    end 
    
    fprintf('[TEST 5] - test close f1(t)\n')
    diff=sum(abs(Ff1(:) - p_Ff1(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(Ff1), size(p_Ff1)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='close f1(t)';
        epsilons(failed_tests)=diff;
    end   

    fprintf('[TEST 6] - test close pdfs eG_FA(t)\n')
    diff=sum(abs(eGFA(:) - p_eGFA(:)));
    fprintf('Diff %d \n\n',diff) 
    if isequal(size(eGFA), size(p_eGFA)) && diff < epsilon
        passed_tests=passed_tests+1;    
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='eGFA(t)';
        epsilons(failed_tests)=diff;
    end
    
    %lets calcuate a likelihood
    
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    [open shut] = RecordingManipulator.getPeriods(resolvedData);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    
    t3=tic;
    log_likelihood=lik.calculate_likelihood(bursts);
    t3=toc(t3);
    
    fprintf('[TEST 7] - likeihood on col 82 sample data\n')
    diff=sum(abs(log_likelihood - p_log_likelihood));
    if diff < epsilon
        passed_tests=passed_tests+1;
    else
        failed_tests=failed_tests+1;
        failed_test_names{failed_tests}='overall likeihood';
        epsilons(failed_tests)=diff;        
    end

    if passed_tests==total_tests
        fprintf('[PASS] - likelihood functions are the same %d tests passed\n\n',total_tests)
    else
        fprintf('[FAIL] - different matrices detected %d Tests failed\n\n',failed_tests)
        for i=1:length(failed_test_names)
            fprintf('Failed test:%s - epsilon %d\n',failed_test_names{i},epsilons(i))
        end
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

