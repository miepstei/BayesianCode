% ion-channel parameterisation of the 10-param SevenState model

%% load the true param values and the guesses
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));

%Preconditioned MALA data from synthetic dataset...
experiment = load(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment44_1198219937.mat'));
kA=experiment.model.kA;
kF = size(experiment.model.generateQ(experiment.startParams,experiment.data.concs(1)),1) - kA;

%options for calculating dcprogs variables
if isfield(experiment,'dcpoptions')
    dcpoptions = experiment.dcpoptions;
else
    dcpoptions{1}=2;
    dcpoptions{2}=1e-12;
    dcpoptions{3}=1e-12;
    dcpoptions{4}=100;
    dcpoptions{5}=-1e6;
    dcpoptions{6}=0; 
end

%% Posterior Param Plot
posterior_density_plot = generate_param_plot(experiment.model.k,5,2,experiment.samples.params(experiment.SamplerParams.Burnin+1:end,:),param_names,true1(ten_param_keys));

%% Sample from the posterior distribution generated
SAMPLES=100;
posterior_samples = datasample(experiment.samples.params(experiment.SamplerParams.Burnin+1:end,:),SAMPLES);

%% Generate unconditional univariate distributions

open_unconditional_plot = generate_unconditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,2,2,kA,kF,dcpoptions);
closed_unconditional_plot = generate_unconditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,0,2,2,kA,kF,dcpoptions);

%% Generate conditional distributions < 0.1 msec
conditional_open_density = generate_conditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,2,2,3,4,[2.5e-5,0.1/1000],dcpoptions);

%% Generate conditional mean distributions
tint = [0.025 0.05;0.05 0.1; 0.1 0.2; 0.2 2; 2 20; 20 200; 200 2000;]/1000;
conditional_open_mean_density = generate_conditional_mean_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,2,2,3,4,tint,dcpoptions);

%%Generate bivariate plot
bivariate_plot = generate_bivariate_plot(experiment,experiment.filenames,'Synthetic',2,2);

%%Simulate some data and generate a 'synthetic' bivariate plot from the
%%first sample (just as an example)
synethic_filenames = generateAchData(experiment.model,experiment.data.concs,[80000,80000,80000],posterior_samples(1,:));
posterior_bivariate_plot = generate_bivariate_plot(experiment,synethic_filenames,'Synthetic',2,2);

%need to be done manually due to dicky scaling
PlotNByM(posterior_density_plot,4,3,1,8,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/posterior_parameters'])
PlotNByM(open_unconditional_plot,2,2,1,16,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_posterior_open_times'],35,25)
PlotNByM(closed_unconditional_plot,2,2,0,16,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_posterior_closed_times'],35,25)
PlotNByM(conditional_open_density,2,2,1,16,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_posterior_conditional_open_times'],35,25)
PlotNByM(conditional_open_mean_density,2,2,1,16,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_posterior_conditional_mean'],35,25)
PlotNByM(bivariate_plot,2,2,1,10,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_bivariate_plot'])
PlotNByM(posterior_bivariate_plot,2,2,1,10,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/synthetic_generated_bivariate_plot'])

close(posterior_density_plot)
close(open_unconditional_plot)
close(closed_unconditional_plot)
close(conditional_open_density)
close(conditional_open_mean_density)
close(bivariate_plot)
close(posterior_bivariate_plot)

clear all
