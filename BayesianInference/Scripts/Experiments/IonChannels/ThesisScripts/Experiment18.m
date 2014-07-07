%%Experiment 18
% SAMPLER: Roberts Adaptive with truncated mala
% NUMBER OF CHAINS: Single Chain
% MODEL: Normal Model from Girolami & Calderhead 2011
% DATASET: generated as per G&C 2011
% SAMPLER: RosenthalAdaptiveSampler

clear all;
experiment_description='Truncated Mala, Roberts Adaptive MCMC, Single Chain, Normal Model, 30 observations, generated as per G&C 2011, RosenthalAdaptiveSampler sampler';

%% sampling parameters
SamplerParams.Samples=1000;
SamplerParams.Burnin=1000;
SamplerParams.AdjustmentLag=100; % scaling
SamplerParams.NotifyEveryXSamples=50;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = NormalModel();

%% Starting Parameters

startParams=[2;2];
clearvars -except experiment_description SamplerParams model startParams
%% Data

load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/NormData30.mat'));

%% Sampling method

proposalScheme = TruncatedMalaProposal(eye(2,2)*1,0.75^2,0.001);

%% Set up the sampler
MCMCsampler = RosenthalAdaptiveSampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
savedir = strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/');
if ~isequal(exist(savedir, 'dir'),7)
    mkdir(savedir)
end
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment18_' , num2str(t.Seed) , '.mat'))