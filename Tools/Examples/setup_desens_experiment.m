function experiment = setup_desens_experiment( )
%UNTITLED Sets up an example experiment (Guess 1 from 2003 paper, C&S1985)
%   with simulated example data, tcrit and tres from 2003 paper. k_2a+ is
%   unconstrained in this model

project_home = getenv('P_HOME');
datafiles={[project_home '/Samples/Simulations/20000/test_1.scn']};
modelfile=[project_home '/Tools/Mechanisms/model_params_CS_1985_2_desens.mat'];
concs = [3e-8];
tcrits= [0.0035];
tres = [0.000025];
use_chs = [1];
debug_on = 1;
fit_logspace=1;
calc_hessian=1;
experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles,modelfile);

end