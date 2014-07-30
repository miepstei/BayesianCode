%%Experiment 37
% SAMPLER: Preconditioned RWMH at mode
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State from Colquhoun2003
% DATASET: 4-concentrations, generated as per Colquhoun2003 to mimic HAttan
% et al dataset
% SAMPLER: Standard

clear all;
experiment_description='Preconditioned RWMH at mode , Single Chain, 7-state concentration dependent, 4-concentrations, generated as per Colquhoun2003, Standard sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=5000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = SevenState_10Param_QET();

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(ten_param_keys)';
clearvars -except experiment_description SamplerParams model startParams

%% Data

data.tres =  [0.00002,0.00002,0.00002,0.00002];
data.concs = [0.0000003,0.000001,0.00001,0.00003];
data.tcrit = [0.0003,0.001,0.007,0.002];
data.useChs= [1 1 0 0];
required_transitions = 10000;


sprintf('Generating data... \n')
filenames = generateAchData(model,data.concs,required_transitions);

for i=1:length(data.concs)
    [data.bursts(i),~] = load_data(filenames(i),data.tres(i),data.tcrit(i));
end

sprintf('Searching for mode... \n')
options = optimset('fminsearch');
options.MaxIter=10000;
options.MaxFunEvals=10000;
options.Display='iter';
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(abs(params),data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f ... \n',fval,x(1),x(2))
mass_m = (model.calcMetricTensor(x,data))^-1;
startParams=x;

%% Sampling method - redefine model
model = SevenState_10Param_AT();
proposalScheme = RwmhProposal(mass_m,0);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
sprintf('MCMC sampling... \n')
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
savedir = strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/');
if ~isequal(exist(savedir, 'dir'),7)
    mkdir(savedir)
end
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment37_' , num2str(t.Seed) , '.mat'))