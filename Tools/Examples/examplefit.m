%%Example model fit
project_home = getenv('P_HOME');

%example data, model and params
datafiles={[project_home '/Samples/Simulations/20000/test_1.scn']};
modelfile=[project_home '/Tools/Mechanisms/model_params_CS 1985_4.mat'];
concs = [3e-8];
tcrits= [0.0035];
tres = [0.000025];
use_chs = [1];
debug_on = 1;
fit_logspace=1;

experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,datafiles,modelfile);

fprintf('***Experiment Description***\n')
fprintf('Model name %s\n',experiment.description.model)
fprintf('Datasets :\n')
for i=1:experiment.description.data.file_number
    fprintf('Dataset %i\n',i)
    fprintf('File name %s\n',experiment.description.data.file_names{i})
    fprintf('Concentration %f\n',concs(i));
    fprintf('tres %f\n',tres(i));
    fprintf('tcrit %f\n',tcrits(i));
    fprintf('Intervals: %i\n',experiment.description.data.dataset(i).interval_no)
    fprintf('Burst number: %i\n',experiment.description.data.dataset(i).burst_no)
    fprintf('Burst length: %.16f\n',experiment.description.data.dataset(i).average_openings_per_burst)
    fprintf('Openings per burst: %.16f\n\n',experiment.description.data.dataset(i).average_burst_length)
end
fprintf('***End of description***\n\n')

fit = fit_experiment(experiment);
