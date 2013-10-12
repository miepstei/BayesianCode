function [ func ] = move_Q_hessian( x ,experiment )
%UNTITLED Test function to move element of q
%   Detailed explanation goes here

    lik = DCProgsExactLikelihood;
    param_map = experiment.model.getParameters(0);
    p_keys = param_map.keys;
    experiment.model.setParameters(containers.Map(p_keys,x));
    experiment.model.updateRates();
    func = lik.calculate_likelihood(experiment);
    experiment.model.setParameters(param_map);

end