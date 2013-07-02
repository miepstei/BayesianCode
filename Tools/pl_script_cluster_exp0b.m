job_id=getenv('SGE_TASK_ID');
cluster_root='/home/ucbpmep/bayesiancode/';

parameter_keys=[1,2,3,4,5,6,11,13,14]; %keys for 1985 model, 9 free params

%gets the parameter from the 
parameter_profile_key=parameter_keys(job_id);

min_rng=[500,20000,2000,10,20000,50,500,5000,200000000];
max_rng=[24000,200000,10000,200,100000,500,3000,15000,600000000];
outfile=[cluster_root 'Results/Exp0b/parameter_key_' num2str(job_id) '.mat'];
datafile=[cluster_root 'Samples/Simulations/20000/test_1.scn'];
mechfile=[cluster_root 'Tools/Mechanisms/model_params_CS 1985_2.mat'];
points=100;
a=tic; 
clusterProfileLikelihood(points,parameter_keys,parameter_profile_key,min_rng,max_rng,outfile,datafile,mechfile);
b=toc(a);
fprintf('Time taken for profile analysis of key %i is %f\n',parameter_profile_key,b)