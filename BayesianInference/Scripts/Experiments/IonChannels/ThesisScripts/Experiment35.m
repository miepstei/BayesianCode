%%Experiment 33
% SAMPLER: smMala at mode
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State from Colquhoun2003
% DATASET: 2-concentrations, generated as per Colquhoun2003
% SAMPLER: Standard

clear all;
experiment_description='smMala at mode , Single Chain, 7-state concentration dependent, 2-concentrations, generated as per Colquhoun2003, Standard sampler';

%% sampling parameters
SamplerParams.Samples=5000;
SamplerParams.Burnin=2500;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = SevenState_10Param_QET();

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(ten_param_keys)';
clearvars -except experiment_description SamplerParams model startParams

%% Data

data.tres =  [0.000025 0.000025];
data.concs = [3e-8 0.00001];
data.tcrit =[0.0035 0.005];
data.useChs=[1 0];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/HighConc/20000/data_3.scn'}),data.tres(2),data.tcrit(2));

options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
options.Display='iter';
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f ... \n',fval,x(1),x(2))
startParams=x;

%% Sampling method - redefine model
model = SevenState_10Param_AT();
proposalScheme = SimpMmalaProposal(eye(model.k,model.k),0);

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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment35_' , num2str(t.Seed) , '.mat'))