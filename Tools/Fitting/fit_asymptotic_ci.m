function [ bounds,err ] = fit_asymptotic_ci( fit,ci )
%FIT_ASYMPTOTIC_CI - calculates the asymptotic confidence intervals after a
%maxiumum likelihood fit.
%INPUTS - fit: a struct containing the maximum likelihood fit
%       - hessian: the observed FI at the maximum likelihood estimates
%       - ci: a confidence interval by which to select the symmetric (e.g.
%       0.95 -> 95 % confidence interval
%OUTPUTS- bounds: a matrix of intervals, [no_param by 2]
%       - err and error code 0 - OK, 1 - uninvertable, 2 - not positive def

num_parameters = size(fit.hessian,1);
bounds = zeros(num_parameters,2);
z_val = norminv(ci,0,1); %this is symmetric
err = 0;

%can we invert the Hessian?
cond_number = rcond(fit.hessian);
if cond_number < eps
    err=1;
    return 
end

%is the Hessian positive definite?
covariance_estimate = fit.hessian^-1;
positivedefinite = all(eig(covariance_estimate) > 0);

if ~positivedefinite
    err=2;
    return      
end

%good to go.
standard_errors = sqrt(diag(covariance_estimate));
ml_estimates = cell2mat(fit.parameters.values);
for i=1:num_parameters
    bounds(i,1)=(-z_val*standard_errors(i))+ml_estimates(i);
    bounds(i,2)=(z_val*standard_errors(i))+ml_estimates(i);
end

