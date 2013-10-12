function experiment = setup_example_experiment( )
%UNTITLED Sets up an example experiment (Guess 1 from 2003 paper, C&S1985)
%   with simulated example data, tcrit and tres from 2003 paper.

project_home = getenv('P_HOME');
datafiles={[project_home '/Samples/Simulations/20000/test_1.scn']};
modelfile=[project_home '/Tools/Mechanisms/model_params_CS 1985_4.mat'];
concs = [3e-8];
tcrits= [0.0035];
tres = [0.000025];
use_chs = [1];
debug_on = 1;
fit_logspace=1;
experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,datafiles,modelfile);

end

