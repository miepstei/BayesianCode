function hessian = calc_hessian(experiment)
    params = experiment.model.getParameters(0);
    param_count = params.Count;
    lik=DCProgsExactLikelihood();
    
    
    hessian = zeros(param_count,param_count);
    start_values = params.values;
    param_keys = params.keys;
    %this will be vectorised
    for i=1:param_count
        for j=i:param_count
            sens_params = containers.Map([param_keys{i} param_keys{j}],[start_values{i} start_values{j}]);
            hessian(i,j) = central_difference(param_keys{i},param_keys{j},lik,experiment,sens_params);
            experiment.model.setParameters(params);
        end
    end
    
    hessian = hessian+triu(hessian,1)'; %fill in the blanks



end

function diff = central_difference(p1,p2,likelihood,experiment,params)
    rate_constant1=params(p1);
    rate_constant2=params(p2);
    h1=0.01;%sqrt(eps);
    h2=0.01;%sqrt(eps);
    
    if p1 ~= p2
        %four function evaluations required for each

        params(p1)=rate_constant1+h1;
        params(p2)=rate_constant2+h2;
        experiment.model.setParameters(params);
        a=likelihood.calculate_likelihood(experiment);
        
        
        params(p1)=rate_constant1+h1;
        params(p2)=rate_constant2-h2;
        experiment.model.setParameters(params);
        b=likelihood.calculate_likelihood(experiment);
        
        
        params(p1)=rate_constant1-h1;
        params(p2)=rate_constant2+h2;
        experiment.model.setParameters(params);
        c=likelihood.calculate_likelihood(experiment);
        
        params(p1)=rate_constant1-h1;
        params(p2)=rate_constant2-h2;
        experiment.model.setParameters(params);
        d=likelihood.calculate_likelihood(experiment);

        diff = (d+a-b-c)/(4*h1*h2);
    else
        %three calculations for the diagonal elements
        experiment.model.setParameters(params);
        f0=likelihood.calculate_likelihood(experiment);        
        params(p1)=rate_constant1+h1;
        experiment.model.setParameters(params);
        f1=likelihood.calculate_likelihood(experiment); 
        params(p1)=rate_constant1-h1;
        experiment.model.setParameters(params);       
        fm1=likelihood.calculate_likelihood(experiment);
        diff = (fm1-(2*f0)+f1)/(h1^2);
    end


end