%%Experiment 47
% SAMPLER:  Preconditioned RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State 13-params from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003 Figure 11
% one channel
% SAMPLER: Standard

clear all;
experiment_description='Preconditioned RWMH , Single Chain, 7-state 10-params concentration dependent, 3-concentrations, experimental data from Hatton 2003 Figure 11, Standard sampler';

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
startParams = [2071.37316885,45826.55905894,125313.75447893,170.09825764,8294.07778271,1.13466114,70707594.17677660,16901.29463903,124.90142986,37777037.80601518]'; %Experiment 46 max posterior params
clearvars -except experiment_description SamplerParams model startParams

%% Data
data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'));

%% Sampling method - redefine model
model = SevenState_10Param_QET();
mass_m = (model.calcMetricTensor(startParams,data))^-1;
proposalScheme = RwmhProposal(mass_m,0);

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment47_' , num2str(t.Seed) , '.mat'))