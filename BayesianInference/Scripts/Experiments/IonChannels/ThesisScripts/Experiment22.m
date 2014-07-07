%%Experiment 22
% SAMPLER: preconditioned RWMH
% NUMBER OF CHAINS: Single Chain
% MODEL: Normal Model from Girolami & Calderhead 2011
% DATASET: generated as per G&C 2011
% SAMPLER: Standard

clear all;
experiment_description='preconditioned RWMH, Single Chain, Normal Model, 30 observations, generated as per G&C 2011, RosenthalAdaptiveSampler sampler';

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

%%Find the empirical mode

options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f ... \n',fval,x(1),x(2))
mass_m = (model.calcMetricTensor(x,data))^-1;
startParams=x;

%% Sampling method

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment22_' , num2str(t.Seed) , '.mat'))