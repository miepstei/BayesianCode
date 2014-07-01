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
model = SevenState_10Param_AT();
startParams=[1500 50000 2000 20 80000 300 1e8 1000 20000 1e8]'; %guess 2

%% Data

data.tres =  [0.000025 0.000025];
data.concs = [3e-8 0.00001];
data.tcrit =[0.0035 0.005];
data.useChs=[1 0];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/HighConc/20000/data_3.scn'}),data.tres(2),data.tcrit(2));

%% Sampling method
proposalScheme = LogRwmhProposal(eye(model.k,model.k)*0.0001,1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/10param/rwmh_adjustment_cw_2concsLog' ,num2str(t.Seed()) ,'.mat'))