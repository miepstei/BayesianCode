
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
        a=tic;
        try
            [min_function_value,fittedRates,~,iter,rejigs,errors,~] = fit_simplex( datafile,paramsFile,1,rand_params );
            fitted_params(i,:) = cell2mat(fittedRates.values);
            fitted_lik(i) = min_function_value;
            fitted_iter(i) = iter;
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
    save(outfile,'fitted_params','fitted_lik','fitted_iter','start_params','fitted_rejigs','fitted_errors')
end


