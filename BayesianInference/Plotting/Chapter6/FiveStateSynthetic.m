data_file = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/ParallelTempering/ION_FiveState_Syn_Posterior_25_100.h5');
NUM_TEMPERATURES = 25;
kA=2;
kF=3;
%ENUM for parameters in model
ALPHA_2=2;
BETA_2=3;

temperatures = (((0:NUM_TEMPERATURES-1)/(NUM_TEMPERATURES-1)).^5);
LogL = h5read(data_file,strcat('/Temperature',num2str(NUM_TEMPERATURES),'/LL'));
Params = h5read(data_file,strcat('/Temperature',num2str(NUM_TEMPERATURES),'/Params'))';

bivariate_scatter = figure('Visible','Off');
scatter(Params(:,ALPHA_2),Params(:,BETA_2),'.');
xlabel('$\alpha$','FontSize',20,'interpreter','LaTeX')
ylabel('$\beta$','FontSize',20,'interpreter','LaTeX')


autocorrelation_figure = figure('Visible','Off');
autocorr(Params(:,ALPHA_2));
title('');
xlabel('Lag','FontSize',20)
ylabel('Sample Autocorrelation','FontSize',20)

likelihood_expectations = zeros(NUM_TEMPERATURES,1);
for i=1:NUM_TEMPERATURES
    LogL = h5read(data_file,strcat('/Temperature',num2str(i),'/LL'));
    likelihood_expectations(i) = mean(LogL);
end
tempering_figure = figure('Visible','Off');
semilogx(temperatures+eps,likelihood_expectations);
xlabel('Temperature','FontSize',20)
ylabel('Expectation of log-likelihood','FontSize',20)

%this is the synthetic data used for the pt experiments
SAMPLES=100;
posterior_samples=datasample(Params,SAMPLES);
experiment = load(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment44_1206427105.mat'));

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

%replace the model in this experiment with the 3-state model
experiment.model = FiveState_8Param_AT();
experiment.startParams =[50,3000,500,15000,2000,15,50,2000]'; 

%we want the lowest concnetration recording so strip the others out
experiment.data.concs = experiment.data.concs(1);
posterior_open_time = generate_unconditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,1,1,kA,kF,dcpoptions);
posterior_shut_time = generate_unconditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,0,1,1,kA,kF,dcpoptions);
tint = [0.025 0.05;0.05 0.1; 0.1 0.2; 0.2 2; 2 20; 20 200; 200 2000;]/1000;
conditional_open_mean_density = generate_conditional_mean_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,1,1,2,3,tint,dcpoptions);

Plot1By1(bivariate_scatter,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_bivariate_scatter'],16,16)
Plot1By1(autocorrelation_figure,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_autocorrelation'],16,16)
Plot1By1(tempering_figure,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_tempering'],16,16)
Plot1By1(posterior_open_time,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_posterior_open_time'],16,16)
Plot1By1(posterior_shut_time,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_posterior_shut_time'],16,16)
Plot1By1(conditional_open_mean_density,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/five_state_conditional_open_mean_density'],16,16)

close(bivariate_scatter)
close(autocorrelation_figure)
close(tempering_figure)
close(posterior_open_time)
close(posterior_shut_time)
close(conditional_open_mean_density)
