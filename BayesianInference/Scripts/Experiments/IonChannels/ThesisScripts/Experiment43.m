%%Experiment 42
% SAMPLER:  Componentwise Multiplicative RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State 13-params from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003, low conc
% one channel
% SAMPLER: Standard

clear all;
experiment_description='Componentwise Multiplicative RWMH , Single Chain, 7-state 13-params concentration dependent, 3-concentrations, experimental data from Hatton 2003, low conc single channel Standard sampler';

%% sampling parameters
SamplerParams.Samples=50000;
SamplerParams.Burnin=25000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(thirteen_param_keys)';
clearvars -except experiment_description SamplerParams model startParams

%% Model
model = SevenState_13param_AT();

%% Data

data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/AchRealDataSingleChannel.mat'));

%% Sampling method - redefine model
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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment43_' , num2str(t.Seed) , '.mat'))