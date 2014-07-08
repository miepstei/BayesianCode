%%Experiment 11
% SAMPLER: MALA 
% NUMBER OF CHAINS: Single Chain
% MODEL: Two State Model from Ball 1989
% DATASET: 4-concentrations, generated as per Ball 1989
% SAMPLER: Standard

clear all;
experiment_description='MALA, Single Chain, 2-state concentration dependent, 4-concentrations, generated as per Ball 1989, MALA sampler';

%% sampling parameters
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=1000; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = TwoState_2param_AT();

%% Starting Parameters

startParams=[100;547394.9172720];
clearvars -except experiment_description SamplerParams model startParams

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

proposalScheme = MalaProposal(eye(model.k,model.k),1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
savedir = strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/');
if ~isequal(exist(savedir, 'dir'),7)
    mkdir(savedir)
end
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment11_' , num2str(t.Seed) , '.mat'))
