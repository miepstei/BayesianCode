%% Sampling parameters
clear all;
SamplerParams.Samples=5000;
SamplerParams.Burnin=2500;
SamplerParams.AdjustmentLag=100;
SamplerParams.NotifyEveryXSamples=5;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;
SamplerParams.ScaleFactor=0.1;

%% Model
model = SevenState_10Param_QET();
startParams=[1896.83121431431 50309.6937905987 5942.08704691863 48.5522163518721 55881.1728863607 86.1441504249738 1512.36703897136 10068.081831692 381587176.53753]'; %from 2003 paper


data.tres =  [0.000025 0.000025];
data.concs = [3e-8 0.00001];
data.tcrit =[0.0035 0.005];
data.useChs=[1 0];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/HighConc/20000/data_1.scn'}),data.tres(2),data.tcrit(2));

%% Sampling method
proposalScheme = SimpMmalaProposalDecomp(1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/decomp_smMala' ,num2str(t.seed()) ,'.mat'))
