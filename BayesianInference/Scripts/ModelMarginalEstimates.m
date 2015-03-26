globs={'ION_ThreeState_Syn_Posterior_25_*','ION_ThreeState_Posterior_25_*','ION_FiveState_Syn_Posterior_25_*','ION_FiveState_Real_Posterior_25_*','ION_SevenState_Syn_Posterior_25_*','ION_SevenState_Real_Posterior_25_*'};

glob_no = length(globs);

mean_marginals = zeros(glob_no,1);
stdev_marginals = zeros(glob_no,1);
marginals = cell(glob_no,1);

for files=1:length(globs)
    d = dir(globs{files});
    d=d([d.bytes]>0);
    estimates = MarginalLikelihoodEstimation (d,0);
    mean_marginals(files) = estimates.mean;
    stdev_marginals(files) = estimates.std;
    marginals{files} = estimates.log_marginals;
    fprintf('Mean Log Marginal Estimate for glob %s  is %.4f standard deviation is %.4f\n',globs{files},mean_marginals(files),stdev_marginals(files));
end

fprintf('*** Bayes Factor Estimation for Synthetic Data ***\n\n');
fprintf('*** Seven State over Five State BF = %.4f\n',mean_marginals(5) - mean_marginals(3));
fprintf('*** Seven State over Three State BF = %.4f\n',mean_marginals(5) - mean_marginals(1));
fprintf('\n');

fprintf('*** Bayes Factor Estimation for Real Data ***\n\n');
fprintf('*** Seven State over Five State BF = %.4f\n',mean_marginals(6) - mean_marginals(4));
fprintf('*** Seven State over Three State BF = %.4f\n',mean_marginals(6) - mean_marginals(2));
fprintf('\n');