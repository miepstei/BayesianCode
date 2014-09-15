%%Experiment 41
% SAMPLER: Adaptive at mode
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003
% SAMPLER: Standard

clear all;
experiment_description='Adaptive at mode , Single Chain, 7-state concentration dependent, 3-concentrations, experimental data from Hatton 2003, Standard sampler';

%% sampling parameters
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(ten_param_keys)';
clearvars -except experiment_description SamplerParams model startParams

%% Model
model = SevenState_10Param_QET();

%% Data

data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/AchRealData.mat'));

options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
options.Display='iter';
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
paramStr=sprintf('%.2f  ',x);
fprintf('Max likelihood is %.4f, params %s ... \n',fval,paramStr)
startParams=x;

%% Sampling method - redefine model
model = SevenState_10Param_AT();
proposalScheme = RwmhMixtureProposal(eye(model.k,model.k),0);

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment41_' , num2str(t.Seed) , '.mat'))