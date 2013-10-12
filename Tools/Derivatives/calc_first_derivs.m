function deriv = calc_first_derivs(param_no,experiment)
    lik=DCProgsExactLikelihood();
    
    %{\partial^2 f \over \partial x_i \partial x_j} =
 %{f(x+h_ie_i+h_je_j) - f(x+h_ie_i) - f(x+h_je_j) + f(x)
 %\over h_i h_j}
    
 %{\partial^2 f \over \partial x^2_i} & = &
 %{-f(x + 2h_ie_i) + 16f(x + h_ie_i) - ...
 %...- f(x+h_ie_i-h_je_j)
 %- f(x-h_ie_i+h_je_j) + f(x-h_ie_i-h_je_j)
 %\over 4h_ih_j}
    params=experiment.model.getParameters(0);
    rate_constant = params(param_no);
    
    h=0.01;%sqrt(eps)*rate_constant;
 
    %f(x+h)
    params(param_no)=rate_constant+h;
    experiment.model.setParameters(params);
    a=lik.calculate_likelihood(experiment);

    %f(x-h)
    params(param_no)=rate_constant-h;
    experiment.model.setParameters(params);
    b=lik.calculate_likelihood(experiment);
    
    deriv=(a-b)/(2*h);
    
    %reset rate
    params(param_no)=rate_constant;
    experiment.model.setParameters(params);
end