function [ bounds, error ] = fit_likelihood_ci( fit,experiment,ci,BOUND_MULTIPLE )
%FIT_LIKELIHOOD_CI Calculates likelihood based CIs for model fit.
%   This is a little more involved than calculating asypmtotic normal ci. 
%   The confidence interval becomes a numerical search for the roots of the
%   equation f(x) - (max(f(x))+chi(ci,1)). We aim to find two roots.
%
%INPUT - fit: the maximum likelihood fit for the experiment
%      - experiment: the struct containing the fitted experiment
%      - ci: the percentage chi-sq to calculate the CI for (usually 0.95)
%      - BOUND_MULTIPLE: a multiple to apply to the search for the CI
%      bounds
%
%OUTPUT - bounds: likelihood based confidence interval bounds for the fir
%       - error: whether the bounds have been successfully established

starting_params = experiment.model.getParameters(0);
num_parameters = length(cell2mat(starting_params.keys));
bounds = zeros(num_parameters,2);
chi = chi2inv(ci,1);
parameter_keys=cell2mat(starting_params.keys);

%create a function handle to the likelihood
lik=DCProgsExactLikelihood;
error=0;

for i=1:num_parameters
    key=parameter_keys(i);
    fprintf('[INFO] - Calculating CI for parameter %i\n\n',key)
    
    fn=@(y1) Q_sens(key,y1,experiment)-(fit.likelihood+chi/2);
    low_search_bounds=[starting_params(key)/BOUND_MULTIPLE starting_params(key)];
    high_search_bounds=[starting_params(key) starting_params(key)*BOUND_MULTIPLE];
    
    [bounds(i,1),~, status]= fzero(fn,low_search_bounds);
    
    if status ~= 1
        fprintf('[WARN] - Failure in Lower root likelihood interval search for %i, exit status %i. Interval [%.4f,%.4f]',i,status,low_search_bounds(1),low_search_bounds(2))
        bounds(i,1)=0;
    else
        
    end
    
    [bounds(i,2),~, status]= fzero(fn,high_search_bounds);
    if status ~= 1
        fprintf('[WARN] - Failure in Upper root likelihood interval search for %i, exit status %i. Interval [%.4f,%.4f]',i,status,high_search_bounds(1),high_search_bounds(2))
        bounds(i,2)=Inf;
    end
    
end

%return state
experiment.model.setParameters(starting_params);


end

