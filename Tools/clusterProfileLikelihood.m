function clusterProfileLikelihood(points,parameter_keys,param_key,min_rng,max_rng,outfile,datafile,mechfile)
       
    %need to generate some starting values
    random_start = zeros(points,length(parameter_keys)-1);
    free_parameter_map=cell(points);
    
    %find the indices and values of all other free params
    free_param_key_idx=find(parameter_keys~=param_key);
    fixed_param_key_idx=find(parameter_keys==param_key);
    free_parameters = parameter_keys(free_param_key_idx);
    
    for j=1:length(free_param_key_idx)   
        random_start(:,j)=randi([min_rng(free_param_key_idx(j)) max_rng(free_param_key_idx(j))],points,1);   
    end
    for profile_point=1:points
        free_parameter_map{profile_point} = containers.Map(int32(free_parameters),random_start(profile_point,:));
    end
    
    fprintf('Profiling likelihood for parameter %i\n',parameter_keys(fixed_param_key_idx))
    [profiles,profile_likelihoods]=profileLikelihood(datafile,mechfile,points,param_key,min_rng(fixed_param_key_idx),max_rng(fixed_param_key_idx),free_parameter_map);
    save(outfile, 'profiles','profile_likelihoods','points','parameter_keys','min_rng','max_rng','outfile','datafile','mechfile','free_parameter_map');

end

