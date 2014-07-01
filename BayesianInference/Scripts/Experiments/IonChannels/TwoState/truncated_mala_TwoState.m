%% truncated Mala
clear all;
SamplerParams.Samples=500000;
SamplerParams.Burnin=250000;
SamplerParams.AdjustmentLag=500;
SamplerParams.NotifyEveryXSamples=100;
%SamplerParams.Tau=0.5;
SamplerParams.ScaleFactor=0.2;
%SamplerParams.gamma = 1;
SamplerParams.LowerAcceptanceLimit=0.4;
SamplerParams.UpperAcceptanceLimit=0.6;

%% Model
model = TwoStateExactIonModel();
startParams=[100;547394.9172720];

%% Data
TRUE_PARAM_1=1000;
TRUE_PARAM_2=10000000;

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [10^-3 10^-4 10^-5 10^-6 ];
data.tcrit =[1 1 1 1];
data.useChs=[0 0 1 1];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

%% Sampling method
proposalScheme = TruncatedMalaProposal(eye(2,2),1,0.01);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/TwoState/TruncatedMala_' ,t.Seed(), '.mat'))