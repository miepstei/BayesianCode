%%Experiment 23
% PROPOSAL: Preconditioned RWMH 
% NUMBER OF CHAINS: Single Chain
% MODEL: Two State Model from Ball 1989
% DATASET: 4-concentrations, generated as per Ball 1989
% SAMPLER: Standard

clear all;
experiment_description='Preconditioned RWMH, Single Chain, 2-state concentration dependent, 4-concentrations, generated as per Ball 1989, RosenthalAdaptiveSampler';

%% sampling parameters
SamplerParams.Samples=50000;
SamplerParams.Burnin=25000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = TwoState_2param_QET();

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

%%Find the empirical mode

options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f ... \n',fval,x(1),x(2))
mass_m = (model.calcMetricTensor(x,data))^-1;


%% Sampling method - redefine model
model = TwoState_2param_AT();
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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment23_' , num2str(t.Seed) , '.mat'))