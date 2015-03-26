real_data_results = strcat(getenv('P_HOME'),{'/BayesianInference/Results/Thesis/ParallelTempering/ION_SevenState_Real_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_FiveState_Real_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_ThreeState_Posterior_25.h5'});
syn_data_results= strcat(getenv('P_HOME'),{'/BayesianInference/Results/Thesis/ParallelTempering/ION_SevenState_Syn_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_FiveState_Syn_Posterior_25.h5','/BayesianInference/Results/Thesis/ParallelTempering/ION_ThreeState_Syn_Posterior_25.h5'});

temperatures = (((0:24)/24).^5);

log_marginals_real = zeros(3,1);
for modelNo=1:3
    posterior_expectations = zeros(25,1);
    results_file=real_data_results{modelNo};
    for i=1:25
        temperature = strcat('/Temperature',num2str(i));
        LogLikelihood=h5read(results_file,strcat(temperature,'/LL'));
        
        %estimate E_{\theta | y,t} [log(y|\theta,t)]
        posterior_expectations(i) = mean(LogLikelihood);
    end
    figure; semilogx(temperatures,posterior_expectations);
    title(results_file);
    log_marginals_real(modelNo) = trapz(temperatures,posterior_expectations);
    fprintf('Log Marginal Likelihood for Real data %s is %.4f\n',results_file,log_marginals_real(modelNo));
end

log_marginals_syn = zeros(3,1);
for modelNo=1:3
    posterior_expectations = zeros(25,1);
    results_file=syn_data_results{modelNo};
    for i=1:25
        temperature = strcat('/Temperature',num2str(i));
        LogLikelihood=h5read(results_file,strcat(temperature,'/LL'));
        
        %estimate E_{\theta | y,t} [log(y|\theta,t)]
        posterior_expectations(i) = mean(LogLikelihood);
    end
    figure; semilogx(temperatures,posterior_expectations);
    title(results_file);
    log_marginals_syn(modelNo) = trapz(temperatures,posterior_expectations);
    fprintf('Log Marginal Likelihood for Synthetic data %s is %.4f\n',results_file,log_marginals_real(modelNo));
end



