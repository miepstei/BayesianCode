%% Sampling parameters
clear all;
SamplerParams.Samples=50000;
SamplerParams.Burnin=25000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;
SamplerParams.ScaleFactor=0.1;

%% Model
model = ThreeState_4param_AT();
startParams=[100;100;100;1000000];

%% Data

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [1e-6 1e-5 1e-4 1e-3];
data.tcrit =[1 1 1 1];
data.useChs=[0 0 1 1];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-06.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-05.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-04.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-03.scn'}),data.tres(4),data.tcrit(4));

%% Sampling method
proposalScheme = LogRwmhProposal(eye(4,4)*0.0001,1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/ThreeState/rwmh_adjustment_cw_log' ,num2str(t.Seed()) ,'.mat'))