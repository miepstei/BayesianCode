job_id=str2num(getenv('SGE_TASK_ID'));
rng(job_id);
min_rng=[13000,120000,4000,10,20000,50,500,1000,150000000]; %[13000,120000,4000,10,20000,50,500,1000,150000000];
max_rng=[20000,200000,8000,200,100000,500,3000,2500,250000000]; %[20000,200000,8000,200,100000,500,3000,2500,250000000];
fprintf('Job id is %i\n',job_id)
parameter_keys=[1,2,3,4,5,6,11,13,14];%[1,2,3,4,5,6,11,13,14]; 
profile_param = parameter_keys(job_id);

outfile=['/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/dcprogs/1ai/parameter_key_' num2str(job_id) '.mat'];
datafiles=strcat('/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo','/', {'Samples/Simulations/20000/test_1.scn'});
modelfile=['/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo' '/' 'Tools/Mechanisms/model_params_CS 1985_4.mat'];
points=3;
concs=[3e-08];
tres=[2.5e-05];
tcrits=[0.0035];
is_log=1;
use_chs =[1];
debug_on=0;

experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,is_log,datafiles,modelfile);

a=tic;
[profiles,profile_likelihoods,profile_errors,profile_iter,profile_rejigs,free_parameter_map]=profileLikelihood(experiment,points,profile_param,min_rng,max_rng);
b=toc(a);

fprintf('Time taken for profile analysis of key %i is %f\n',profile_param,b)
save(outfile, 'profile_errors','profile_iter','profile_rejigs','profiles','profile_likelihoods','points','parameter_keys','min_rng','max_rng','outfile','datafiles','modelfile','free_parameter_map');

