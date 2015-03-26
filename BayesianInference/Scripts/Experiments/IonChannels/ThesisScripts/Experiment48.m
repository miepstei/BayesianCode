%%Experiment 46
% SAMPLER:  Componentwise Multiplicative RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State 13-params from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003 Figure 11
% one channel
% SAMPLER: Standard

clear all;
experiment_description='Componentwise Multiplicative RWMH , Single Chain, 3-state 4-params concentration dependent, 3-concentrations, experimental data from Hatton 2003 Figure 11, low conc single channel Standard sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=100;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Starting Parameters
startParams=[100,100,1000,1000]';
clearvars -except experiment_description SamplerParams model startParams

%% Data
data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'));

%% Sampling method - redefine model
model = ThreeState_4Param_AT();
proposalScheme = LogRwmhProposal(eye(model.k,model.k),1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
savedir = strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/');
if ~isequal(exist(savedir, 'dir'),7)
    mkdir(savedir)
end
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment48_' , num2str(t.Seed) , '.mat'))