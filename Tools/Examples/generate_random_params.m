function params = generate_random_params(experiment)

    init_params=experiment.model.getParameters(false);
    random_start = zeros(1,init_params.Count);
    
    min_rng(1:init_params.Count)=1;
    max_rng(1:init_params.Count)=1e5;
    max_rng(end)=5e8;
    for j=1:length(min_rng)
        random_start(j)=randi([min_rng(j) max_rng(j)],1,1);
    end

    parameter_keys = cell2mat(experiment.model.getParameters(true).keys);
    params = containers.Map(int32(parameter_keys),random_start);
end

