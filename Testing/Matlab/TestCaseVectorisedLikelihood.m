function TestCaseVectorisedLikelihood(paramsFile,verbose)

    test_params = Test_Setup(paramsFile);
    
    test_names={'[TEST 1] - check open vectorised pdfs','[TEST 2] - check closed vectorised pdfs','[TEST 3] - check likelihoods'};
    
    total_tests=3;
    passed_tests=zeros(total_tests,1);
    diffs=zeros(total_tests,1);
    

    epsilon = test_params.epsilon;
    
    %setup data
    lik = ExactLikelihood();
    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;
    test_params.islogspace=true;
    test_params.debugOn=true;

    lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    tresol=test_params.tres;
    log_likelihood=0;

    vectorised_pdf_timing = tic;
    %calculate array of open and shut times here
    
    [open_times,closed_times,~,l_openings] = lik.calculate_burst_parameters(bursts);
    %withinbursts=[bursts.withinburst];
    %time_intervals=[withinbursts.intervals];

    %l_openings=[withinbursts.amps]>0;
    %l_closings=logical(ones(1,length(l_openings))-l_openings);

    %open_times=time_intervals(l_openings);
    %closed_times=time_intervals(l_closings);

    %calculate pdfs of open ans shut times
    %open_times=open_times(1:10);

    obj=lik;
    open_pdfs = ExactLikelihood.exact_pdf_vectorised(lik.eig_valsQ,lik.a_AR,lik.open_roots,lik.AZ00,lik.AZ10,lik.AZ11,open_times,tresol,lik.Q_rep.Q_AF,obj.expFF);
    closed_pdfs = ExactLikelihood.exact_pdf_vectorised(obj.eig_valsQ,obj.f_AR,obj.closed_roots,obj.FZ00,obj.FZ10,obj.FZ11,closed_times,tresol,obj.Q_rep.Q_FA,obj.expAA);

    open_times_scalar=zeros(size(open_pdfs));
    closed_times_scalar=zeros(size(closed_pdfs));

    vectorised_pdf_timing=toc(vectorised_pdf_timing);
    %compare these pdfs to the scalar way

    simple_pdf_timing = tic;
    o_t=1;
    c_t=1;
    intervals=1;
    for i=1:length(bursts)
        burst = bursts(i);
        for j=1:length(burst.withinburst.intervals)
            if l_openings(intervals) %opening
                open_times_scalar(o_t,:,:) = ExactLikelihood.exact_pdf(obj.eig_valsQ,obj.a_AR,obj.open_roots,obj.AZ00,obj.AZ10,obj.AZ11,burst.withinburst.intervals(j),tresol,obj.Q_rep.Q_AF,obj.expFF);
                o_t=o_t+1;
            else
                closed_times_scalar(c_t,:,:) = ExactLikelihood.exact_pdf(obj.eig_valsQ,obj.f_AR,obj.closed_roots,obj.FZ00,obj.FZ10,obj.FZ11,burst.withinburst.intervals(j),tresol,obj.Q_rep.Q_FA,obj.expAA);
                %individual_lik = obj.exact_close_pdf(obj,burst.withinburst.intervals(j));
                c_t=c_t+1;
            end
            intervals=intervals+1;
        end
    end

    simple_pdf_timing = toc(simple_pdf_timing);

    %lets get the actual likelihood calculations and timings
    clear lik;
    simple_timing = tic;
    lik = ExactLikelihood();
    lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    simple_likelihood = lik.calculate_likelihood(bursts);
    simple_timing=toc(simple_timing);
    
    clear lik open_times closed_times l_openings;
    vectorised_timing = tic;
    lik = ExactLikelihood();
    lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);

    [open_times,closed_times,withinburst_count,l_openings] = lik.calculate_burst_parameters(bursts);
    vectorised_likelihood = lik.calculate_likelihood_vectorised(bursts,open_times,closed_times,withinburst_count,l_openings);
    vectorised_timing=toc(vectorised_timing);
    
    fprintf('[BEGINNING UNIT TESTS] - at concentration = %e\n',test_params.conc)

    [passed_tests(1),diffs(1)] = TestCompare(open_pdfs,open_times_scalar,epsilon); 
    [passed_tests(2),diffs(2)] = TestCompare(closed_pdfs,closed_times_scalar,epsilon); 
    [passed_tests(3),diffs(3)] = TestCompare(simple_likelihood,vectorised_likelihood,epsilon); 

    if verbose
        % *** SUMMARY OF TEST RESULTS ***

        passed = sum(passed_tests);
        failed = total_tests-passed;

        if sum(passed_tests)==total_tests
            fprintf('[ALL TESTS PASSED] - Simple and vectorised open and closed time pdfs and likelihoods are the same %d tests passed\n\n',total_tests)
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
        fprintf('\n\n')
        fprintf('Simple pdf calc takes %.2f seconds\n', simple_pdf_timing )
        fprintf('Vectorised pdf calc takes %.2f seconds\n', vectorised_pdf_timing )
        fprintf('Simple Total Likelihood calc takes %.2f seconds\n', simple_timing )
        fprintf('Vectorised Total Likelihood calc takes %.2f seconds\n',vectorised_timing)
    end
    save(test_params.setupOutFile, 'test_names','passed_tests','diffs','open_pdfs','open_times_scalar','closed_pdfs','closed_times_scalar','simple_likelihood','vectorised_likelihood')
    %log_vec_likelihood=lik.calculate_likelihood_vectorised(bursts);
end
