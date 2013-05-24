%('Samples/Simulations/1985/test_1.scn','Tools/Mechanisms/model_params_CS 1985_2.mat',100,1)

parameter_keys=[1,2,3,4,5,6,11,13,14]; %keys for 1985 model

points=2;
param_no=length(parameter_keys);
profiles=zeros(param_no,points,param_no);
profile_likelihoods=zeros(param_no,points);

parfor i=1:length(parameter_keys)
    [profiles(i,:,:),profile_likelihoods(i,:)] = profileLikelihood('Samples/Simulations/1985/test_1.scn','Tools/Mechanisms/model_params_CS 1985_2.mat',points,parameter_keys(i));
end

save('Samples/profile.mat', 'profiles','profile_likelihoods');

