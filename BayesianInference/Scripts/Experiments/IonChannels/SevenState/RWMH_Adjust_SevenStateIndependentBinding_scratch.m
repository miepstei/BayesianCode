%% Sampling parameters
clear all;
SamplerParams.Samples=50000;
SamplerParams.Burnin=25000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;
SamplerParams.ScaleFactor=0.2;

%% Model
model = SevenState_9param_AT();
startParams=[1500;50000;13000;50;15000;10;6000;5000;100000000];
%% Data

data.tres =  0.000025 ;
data.concs = 3e-8 ;
data.tcrit =0.0035;
data.useChs=1;

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));

%% Sampling method
proposalScheme = LogRwmhProposal(eye(9,9)*0.0001,1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/rwmh_adjustment_scratch' ,num2str(t.Seed()) ,'.mat'))