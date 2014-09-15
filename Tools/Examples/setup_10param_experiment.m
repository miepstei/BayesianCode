function experiment = setup_10param_experiment( )
project_home = getenv('P_HOME');
modelfile=[project_home '/Tools/Mechanisms/model_params_CS_1985_k_+2a_unconstrained_guess1.mat'];

datafiles=strcat(project_home, {'/Samples/Simulations/20000/test_2.scn','/Samples/Simulations/HighConc/20000/data_2.scn'});
concs = [3e-8 0.00001];
tcrits= [0.0035 0.005];
tres = [0.000025 0.000025];
use_chs = [1 0];
debug_on = 1;
fit_logspace=1;
calc_hessian=0;



experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles,modelfile);

%setup guess 2 on this experiment
guess2 = containers.Map([1,2,3,4,5,6,8,11,13,14],[1500 50000 2000 20 80000 300 1e8 1000 20000 1e8]);
experiment.model.setParameters(guess2);

end

