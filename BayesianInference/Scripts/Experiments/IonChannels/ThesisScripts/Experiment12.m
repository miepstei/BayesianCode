%%Experiment 12
% SAMPLER: TRUNCATED MALA 
% NUMBER OF CHAINS: Single Chain
% MODEL: Normal Model from Girolami & Calderhead 2011
% DATASET: generated as per G&C 2011
% SAMPLER: Standard

clear all;
experiment_description='Truncated MALA, Single Chain, Normal Model, 30 observations, generated as per G&C 2011, Standard sampler';

%% sampling parameters
SamplerParams.Samples=1000;
SamplerParams.Burnin=1000;
SamplerParams.AdjustmentLag=200; % scaling
SamplerParams.NotifyEveryXSamples=100;
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

proposalScheme = TruncatedMalaProposal(eye(2,2)*0.1,1,10);

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment12_' , num2str(t.Seed) , '.mat'))