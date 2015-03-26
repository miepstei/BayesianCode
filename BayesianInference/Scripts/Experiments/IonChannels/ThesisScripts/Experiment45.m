%%Experiment 45
% SAMPLER: Preconditioned RWMH at mode
% NUMBER OF CHAINS: Single Chain
% MODEL: Seven State from Colquhoun2003 13 params
% DATASET: 3-concentrations, generated as per Hatton2003 to mimic HAttan
% from depnendent binding sites
% et al dataset
% SAMPLER: Standard

clear all;
experiment_description='Preconditioned RWMH at mode , Single Chain, 7-state concentration dependent, 3-concentrations, generated as per Hatton2003, Dependent binding, Standard sampler';

%% sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% Model
model = SevenState_13param_QET();

%% Starting Parameters
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
startParams=guess2(thirteen_param_keys)';


%% Data

data.tres =  [0.000025,0.000025,0.000025];
data.concs = [0.00000005 0.0000001 0.00001];
data.tcrit = [0.002 0.0035 0.035 ];
data.useChs= [1 1 0];
required_transitions = [20000 53000 20000];


sprintf('Generating data... \n')
generativeParams = true2(thirteen_param_keys);
desensParams = [generativeParams 5 1.4];

filenames = generateAchData(SevenState_13param_QET(),data.concs(1:2),required_transitions(1:2),generativeParams);
filenames(3) = generateAchData(EightState_15Param_AT(),data.concs(3),required_transitions(3),desensParams);

for i=1:length(data.concs)
    [data.bursts(i),~] = load_data(filenames(i),data.tres(i),data.tcrit(i));
    sprintf('Burst length set %i -> %.4f... \n',i,length(data.bursts{i}))
end

clearvars -except experiment_description SamplerParams model startParams data filenames generativeParams desensParams required_transitions

sprintf('Searching for mode... \n')
options = optimset('fminsearch');
options.MaxIter=10000;
options.MaxFunEvals=10000;
options.Display='iter';
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogPosterior(params,data),startParams,options);
paramStr=sprintf('%.2f  ',x);
fprintf('Max likelihood is %.4f, params %s ... \n',fval,paramStr)
mass_m = (model.calcMetricTensor(x,data))^-1;
startParams=x;

%% Sampling method - redefine model
model = SevenState_13param_AT();
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
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Experiment45_' , num2str(t.Seed) , '.mat'))