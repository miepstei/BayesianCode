%%Experiment 46
% SAMPLER:  Componentwise Multiplicative RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State 13-params from Colquhoun2003
% DATASET: 3-concentrations, experimental data from Hatton 2003 Figure 11
% one channel
% SAMPLER: Standard

clear all;
experiment_description='Componentwise Multiplicative RWMH , Single Chain, 7-state 10-params concentration dependent, 3-concentrations, experimental data from Hatton 2003 Figure 11, low conc single channel Standard sampler';

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
startParams=hatton2003(ten_param_keys);
clearvars -except experiment_description SamplerParams model startParams

%% Model
model = SevenState_10Param_QET();

%% Data

data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'));

% sprintf('Searching for mode... \n')
% options = optimset('fminsearch');
% options.MaxIter=10000;
% options.MaxFunEvals=10000;
% options.Display='iter';
% [x,fval,exitflag] = fminsearch(@(params)-model.calcLogPosterior(params,data),startParams,options);
% paramStr=sprintf('%.2f  ',x);
% fprintf('Max likelihood is %.4f, params %s ... \n',fval,paramStr)
% mass_m = (model.calcMetricTensor(x',data))^-1;
% startParams=x';

%% Sampling method - redefine model
model = SevenState_10Param_AT();
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