%%Experiment B
% SAMPLER: multiplicative Metropolis-Hastings with adjustment 
% NUMBER OF CHAINS: Single Chain
% MODEL: 7-state concentration dependent, 10 params
% DATASET: 2-concentrations, generated as per Colqhoun 2003, 30nm, 10 um, 20000
% intervals each
% SAMPLER: Standard
clear all;
experiment_description='multiplicative Metropolis-Hastings with compnentwise adjustment, Single Chain, 7-state concentration dependent, 2-concentrations, generated as per Colquhoun 2003, Standard MH Sampler';

%% sampling parameters
SamplerParams.Samples=200000;
SamplerParams.Burnin=100000;
SamplerParams.AdjustmentLag=50; % scaling
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = SevenState_10Param_AT();

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(ten_param_keys)';
clearvars -except experiment_description SamplerParams model startParams

%% Data
data.tres =  [0.000025 0.000025];
data.concs = [3e-8 0.00001];
data.tcrit =[0.0035 0.005];
data.useChs=[1 0];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/HighConc/20000/data_3.scn'}),data.tres(2),data.tcrit(2));

%% Sampling method

Componentwise = 1;
proposalScheme = LogRwmhProposal(eye(model.k,model.k),Componentwise);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
mkdir(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/'))
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/ExperimentB_' , num2str(t.Seed) , '.mat'))