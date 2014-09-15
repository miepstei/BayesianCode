function experiment = setup_two_state_experiment()
%UNTITLED Sets up an example experiment (Guess 1 from 2003 paper, C&S1985)
%   with simulated example data, tcrit and tres from 2003 paper. 

project_home = getenv('P_HOME');
datafiles=strcat(project_home, {'/Samples/Simulations/two_state_20000.scn'});
modelfile=[project_home '/Tools/Mechanisms/model_params_TwoState.mat'];
concs = [3e-8];
tcrits= [1 ];  %usually 0.0035
tres = [0 ]; %usually 0.000025
use_chs = [1 ];
debug_on = 0;
fit_logspace=1;
calc_hessian=1;
experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles,modelfile);

end