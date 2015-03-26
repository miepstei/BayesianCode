function marginalEstimates = MarginalLikelihoodEstimation (d,debug,chainNo)

    no_experiments = length(d);
    log_marginals = zeros(no_experiments,1);
    temperatures = (((0:chainNo-1)/(chainNo-1)).^5);

    for estimate=1:no_experiments
        posterior_expectations = zeros(chainNo,1);
        results_file=d(estimate).name;
        for i=1:chainNo
            temperature = strcat('/Temperature',num2str(i));
            try
                LogLikelihood=h5read(results_file,strcat(temperature,'/LL'));
            catch
                error('Unable to read file %s\n',results_file)
            end

            %estimate E_{\theta | y,t} [log(y|\theta,t)]
            posterior_expectations(i) = mean(LogLikelihood);
            if length(LogLikelihood(LogLikelihood==0)) > 0
                fprintf('Log Marginal Likelihood zeros for %s is %.4f\n',results_file,length(LogLikelihood(LogLikelihood==0)));
            end
        end
        if debug
            figure; semilogx(temperatures,posterior_expectations);
            title(results_file);
        end
        log_marginals(estimate) = trapz(temperatures,posterior_expectations);
        if debug
            fprintf('Log Marginal Likelihood for Real data %s is %.4f\n',results_file,log_marginals(estimate));
        end
    end

    if debug
        fprintf('Mean Log Marginal Estimate is %.4f standard deviation is %.4f\n\n',mean(log_marginals),std(log_marginals));
    end
    
    marginalEstimates.log_marginals=log_marginals;
    marginalEstimates.mean = mean(log_marginals);
    marginalEstimates.std = std(log_marginals);
end
