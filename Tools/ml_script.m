
function ml_script(outfile,random_starts,datafile,paramsFile)
    %This is a script to perform ML fit to a dataset given a
    %specified mechanism - 1985 independent binding site mechanism
    %number of random fittings to make
    %ARGUMENTS: random_starts=100;
    %           outfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/ml_100_random_fits.mat';
    %           datafile=''
    %           paramsFile=''

    parameter_keys=[1,2,3,4,5,6,11,13,14]; %keys for 1985 model, 9 free params
    min_range=[500,20000,2000,10,20000,50,500,5000,200000000];
    max_range=[24000,200000,10000,200,100000,500,3000,15000,600000000];
    %datafile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Samples/Simulations/20000/test_1.scn';
    %paramsFile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Tools/Mechanisms/model_params_CS 1985_2.mat';

    load(paramsFile);

    [~,data]=DataController.read_scn_file(datafile);
    data.intervals=data.intervals/1000;

    test_params.mechanism=ModelSetup(paramsFile); %'/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_4.mat');
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.tres = tres; 
    test_params.tcrit = tcrit; %separation of time between bursts  
    test_params.isCHS = 1; % use CHS vectors
    test_params.data = data;
    test_params.conc = concentration;

    %preprocess data and apply resolution
    resolvedData = RecordingManipulator.imposeResolution(data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;

    %prepare the dataset for likelihood calc
    lik = ExactLikelihood();
    [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
    clear lik; 



    fitted_params=zeros(random_starts,length(parameter_keys));
    fitted_lik = zeros(random_starts,1);
    fitted_iter = zeros(random_starts,1);
    fitted_rejigs = zeros(random_starts,1);
    fitted_errors = zeros(random_starts,1);

    start_params=zeros(random_starts,length(parameter_keys));

    c=tic;
    for i=1:random_starts
        %generate random starting points for the algorithm
        rand_params = containers.Map('KeyType', 'int32','ValueType','any');
        for j=1:length(parameter_keys)
            rand_params(parameter_keys(j)) = randi([min_range(j) max_range(j)],1);
        end
        start_params(i,:)=cell2mat(rand_params.values);

        %set the params on the mechanism
        test_params.mechanism.setParameters(rand_params);

        lik = ExactLikelihood();
        [test_params.open_times,test_params.closed_times,test_params.withinburst_count,test_params.l_openings]=lik.calculate_burst_parameters(bursts);
        init_params=test_params.mechanism.getParameters(true);
        splx=Simplex();

        a=tic;
        try
            [min_function_value,min_parameters,iter,rejigs,errors,~]=splx.run_simplex(lik,init_params,test_params);
            fitted_params(i,:) = cell2mat(min_parameters.values);
            fitted_lik(i) = min_function_value;
            fitted_iter(i) = iter
            fitted_rejigs(i) = rejigs;
            fitted_errors(i) = errors;
        catch err
            disp('[ERROR]: in evaluating Simplex')
            disp(err)
            fitted_params(i,:) = NaN;
            %by default but best to be explicit
            fitted_lik(i) = 0;
            fitted_errors(i) = -1;
            fitted_iter(i) = 0;
        end
        b=toc(a);
        fprintf('%ith fit taken %f secs\n',i,b)

    end
    d=toc(c);
    fprintf('\nsecs taken OVERALL = %f\n',d)
    save(outfile,'fitted_params','fitted_lik','fitted_iter','start_params')
end


