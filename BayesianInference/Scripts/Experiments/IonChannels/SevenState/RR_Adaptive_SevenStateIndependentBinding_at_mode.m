%% Sampling parameters
clear all;
SamplerParams.Samples=200000;
SamplerParams.Burnin=100000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;
SamplerParams.ScaleFactor=0.1;

%% Model
model = SevenState_9param_AT();
startParams=[1896.83121431431 50309.6937905987 5942.08704691863 48.5522163518721 55881.1728863607 86.1441504249738 1512.36703897136 10068.081831692 381587176.53753]'; %from 2003 paper

%true1 generative values = [2000,52000,6000,50,50000,150,1500,2*10^8,10000,4*10^8,1500,2*10^8,10000,4*10^8]
%for Dependent binding sites

data.tres =  0.000025 ;
data.concs = 3e-8 ;
data.tcrit =0.0035;
data.useChs=1;

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));


%% Sampling method
proposalScheme = RwmhMixtureProposal(eye(model.k,model.k),0);

%% Set up the sampler
MCMCsampler = RosenthalAdaptiveSampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/RR_Adaptive' ,num2str(t.Seed()), '_at_mode.mat'))