%%Experiment 46
% SAMPLER:  Componentwise Multiplicative RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State 10-params from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003 Figure 11
% one channel
% SAMPLER: Standard

clear all;
experiment_description='Componentwise Multiplicative RWMH , Single Chain, 7-state 10-params concentration dependent, 3-concentrations, experimental data from Hatton 2003 Figure 11, Standard sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=100;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=[1900.0 50046 3939.1 82.36 40099 0.95 44300000 10000 80.45 2.81E+08]';%REMIS LP STARTING VALUES;
%startParams = [2097.5 45614 285.93 2.0779 12970 0.93333 6.4269e+07 17282 82.549 3.5075e+07]'; %DCPYPS MAX LIKELIHOOD
clearvars -except experiment_description SamplerParams model startParams

%% Data
data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'));

%% Sampling method - redefine model
model = SevenState_10Param_QET();
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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment46_' , num2str(t.Seed) , '.mat'))