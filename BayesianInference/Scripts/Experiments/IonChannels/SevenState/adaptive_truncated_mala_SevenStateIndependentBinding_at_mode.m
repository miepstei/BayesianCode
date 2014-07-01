%% Adaptive MCMC with truncated Mala
clear all;
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = SevenState_9param_AT();
startParams=[1896.83121431431 50309.6937905987 5942.08704691863 48.5522163518721 55881.1728863607 86.1441504249738 1512.36703897136 10068.081831692 381587176.53753]'; %mode

%% Data

data.tres =  0.000025 ;
data.concs = 3e-8 ;
data.tcrit =0.0035;
data.useChs=1;

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));

%% Sampling method
proposalScheme = TruncatedMalaProposal(eye(model.k,model.k),1,0.01);

%% Set up the sampler
MCMCsampler = RosenthalAdaptiveSampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/AdaptiveTruncatedMala_' ,num2str(t.Seed()) ,'_at_mode.mat'))