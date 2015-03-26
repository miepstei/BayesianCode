
data_file = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/ParallelTempering/ION_ThreeState_Syn_Posterior_25.h5');
NUM_TEMPERATURES = 25;
kA=1;
kF=2;
%ENUM for parameters in model
ALPHA=1;
BETA=2;

temperatures = (((0:NUM_TEMPERATURES-1)/(NUM_TEMPERATURES-1)).^5);
LogL = h5read(data_file,strcat('/Temperature',num2str(NUM_TEMPERATURES),'/LL'));
Params = h5read(data_file,strcat('/Temperature',num2str(NUM_TEMPERATURES),'/Params'))';

bivariate_scatter = figure('Visible','Off');
scatter(Params(:,ALPHA),Params(:,BETA),'.');
xlabel('$\alpha$','FontSize',20,'interpreter','LaTeX')
ylabel('$\beta$','FontSize',20,'interpreter','LaTeX')

autocorrelation_figure = figure('Visible','Off');
autocorr(Params(:,ALPHA));
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
experiment.model = ThreeState_4Param_AT();
experiment.startParams = [100;100;1000;1000];

%we want the lowest concnetration recording so strip the others out
experiment.data.concs = experiment.data.concs(1);
posterior_open_time = generate_unconditional_plot(experiment,experiment.filenames,'Synthetic',posterior_samples,1,1,1,kA,kF,dcpoptions);

Plot1By1(bivariate_scatter,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/three_state_bivariate_scatter'],16,16)
Plot1By1(autocorrelation_figure,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/three_state_autocorrelation'],16,16)
Plot1By1(tempering_figure,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/three_state_tempering'],16,16)
Plot1By1(posterior_open_time,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/three_state_posterior_open_time'],16,16)

close(bivariate_scatter)
close(autocorrelation_figure)
close(tempering_figure)
close(posterior_open_time)