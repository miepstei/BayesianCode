%%Experiment 7
% SAMPLER: multiplicative Metropolis-Hastings with componentwise adjustment 
% NUMBER OF CHAINS: Single Chain
% MODEL: 7-state concentration dependent, 9 params
% DATASET: 1-concentrations, generated as per Colqhoun 2003, 30nm 20000
% intervals
% SAMPLER: Standard
clear all;
experiment_description='multiplicative Metropolis-Hastings with componentwise adjustment, Single Chain, 7-state concentration dependent, 1-concentrations, generated as per Colquhoun 2003, Standard MH Sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;
SamplerParams.AdjustmentLag=50; % scaling
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = SevenState_9param_AT();

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(nine_param_keys);
clearvars -except experiment_description SamplerParams model startParams
%% Data

data.tres =  0.000025 ;
data.concs = 3e-8 ;
data.tcrit =0.0035;
data.useChs=1;

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));


%% Sampling method

Componentwise = 1;
proposalScheme = LogRwmhProposal(eye(model.k,model.k),Componentwise);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
mkdir(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/'))
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment7_' , num2str(t.Seed) , '.mat'))