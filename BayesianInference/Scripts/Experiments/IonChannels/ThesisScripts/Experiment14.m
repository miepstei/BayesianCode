%%Experiment 14
% SAMPLER: Simplified mMALA 
% NUMBER OF CHAINS: Single Chain
% MODEL: Normal Model from Girolami & Calderhead 2011
% DATASET: generated as per G&C 2011
% SAMPLER: Standard

clear all;
experiment_description='Simplified mMALA, Single Chain, Normal Model, 30 observations, generated as per G&C 2011, Standard sampler';

%% sampling parameters
SamplerParams.Samples=50;
SamplerParams.Burnin=50;
SamplerParams.AdjustmentLag=50; % scaling
SamplerParams.NotifyEveryXSamples=50;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = NormalModel();

%% Starting Parameters

startParams=[2;2];
clearvars -except experiment_description SamplerParams model startParams
%% Data

load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/NormData30.mat'));

%% Sampling method

proposalScheme = SimpMmalaProposal(1);

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment14_' , num2str(t.Seed) , '.mat'))