function lik = calcLL(params,data,model)
    lik = -model.calcLogLikelihood(params,data);
end