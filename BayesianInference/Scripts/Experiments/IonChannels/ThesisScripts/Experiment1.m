%%Experiment 1
% SAMPLER: Metropolis-Hastings with no adjustment 
% NUMBER OF CHAINS: Single Chain
% MODEL: 2-state concentration dependent
% DATASET: 4-concentrations, generated as per Ball 1989
% SAMPLER: Standard

experiment_description='Metropolis-Hastings with no adjustment, Single Chain, 2-state concentration dependent, 4-concentrations, generated as per Ball 1989, Standard MH Sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=20000;
SamplerParams.AdjustmentLag=20000; % no adjustment in this script
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = TwoState_2param_AT();

%% Starting Parameters
startParams=[100;547394.9172720];

%% Data

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [10^-3 10^-4 10^-5 10^-6 ];
data.tcrit =[1 1 1 1];
data.useChs=[0 0 1 1];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

%% Sampling method

NoComponentwise = 0;
proposalScheme = RwmhProposal(eye(model.k,model.k),NoComponentwise);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
mkdir(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/'))
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment1_' , num2str(t.Seed) , '.mat'))