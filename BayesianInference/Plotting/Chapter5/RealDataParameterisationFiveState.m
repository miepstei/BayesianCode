% ion-channel parameterisation of the 8-param FiveState model

%% load the true param values and the guesses
%load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));

%Preconditioned MALA data from synthetic dataset...
experiment = load(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/RealData/Adaptive/Experiment51_RwmhMixtureProposal_1630372693.mat'));
experiment.startParams=experiment.mapStartParams;
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

param_names = {'\alpha_1','\alpha_2','\beta_2','km_2','kp_2','\beta_1','km_1','kp_1'};

%we want to show the autocorrelation for the first param
autocorr(experiment.samples.params(experiment.SamplerParams.Burnin+1:end,2),50);
alpha_autocorrelation=gcf;
title('')
set(alpha_autocorrelation,'Visible','Off');

%we want to show the scatter for the alpha and beta
pairwise_posterior=figure('visible','off');
scatter(experiment.samples.params(experiment.SamplerParams.Burnin+1:end,2),experiment.samples.params(experiment.SamplerParams.Burnin+1:end,3),'.');
title('')
xlabel(param_names{2})
ylabel(param_names{3})

%% Posterior Param Plot
posterior_density_plot = generate_param_plot(experiment.model.k,4,2,experiment.samples.params(experiment.SamplerParams.Burnin+1:end,:),param_names);

%% Sample from the posterior distribution generated
SAMPLES=100;
posterior_samples = datasample(experiment.samples.params(experiment.SamplerParams.Burnin+1:end,:),SAMPLES);

%% Generate unconditional univariate distributions of first concnetration
experiment.data.concs = experiment.data.concs(1);

open_unconditional_plot = generate_unconditional_plot(experiment,experiment.data.resolved_data,'Experimental',posterior_samples,1,1,1,kA,kF,dcpoptions);
closed_unconditional_plot = generate_unconditional_plot(experiment,experiment.data.resolved_data,'Experimental',posterior_samples,0,1,1,kA,kF,dcpoptions);

%% Generate conditional distributions < 0.1 msec
conditional_open_density = generate_conditional_plot(experiment,experiment.data.resolved_data,'Experimental',posterior_samples,1,1,1,2,3,[2.5e-5,0.1/1000],dcpoptions);

%% Generate conditional mean distributions
tint = [0.025 0.05;0.05 0.1; 0.1 0.2; 0.2 2; 2 20; 20 200; 200 2000;]/1000;
conditional_open_mean_density = generate_conditional_mean_plot(experiment,experiment.data.resolved_data,'Experimental',posterior_samples,1,1,1,2,3,tint,dcpoptions);

%%Generate bivariate plot
%bivariate_plot = generate_bivariate_plot(experiment,experiment.data.resolved_data,'Experimental',2,2);

%%Simulate some data and generate a 'synthetic' bivariate plot from the
%%first sample (just as an example)
%synethic_filenames = generateAchData(experiment.model,experiment.data.concs,[80000,80000,80000],posterior_samples(1,:));
%posterior_bivariate_plot = generate_bivariate_plot(experiment,synethic_filenames,2,2);

Plot1By1(pairwise_posterior,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_alpha_beta_bivariate'])
Plot1By1(alpha_autocorrelation,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_alpha_autocorrelation'])
PlotNByM(posterior_density_plot,4,2,1,8,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_posterior_parameters'])
Plot1By1(open_unconditional_plot,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_posterior_open_times'],16,16)
Plot1By1(closed_unconditional_plot,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_posterior_closed_times'],16,16)
Plot1By1(conditional_open_density,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_posterior_conditional_open_times'],16,16)
Plot1By1(conditional_open_mean_density,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_posterior_conditional_mean'],16,16)
%PlotNByM(bivariate_plot,2,2,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/five_state_real_data_bivariate_plot'])
%PlotNByM(posterior_bivariate_plot,2,2,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/real_data_generated_bivariate_plot'])


close(pairwise_posterior)
close(alpha_autocorrelation)
close(posterior_density_plot)
close(open_unconditional_plot)
close(closed_unconditional_plot)
close(conditional_open_density)
close(conditional_open_mean_density)
%close(bivariate_plot)
%close(posterior_bivariate_plot)

clear all