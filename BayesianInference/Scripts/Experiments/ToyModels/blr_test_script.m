%% Sampling parameters
clear all;
SamplerParams.Samples=10000;
SamplerParams.Burnin=5000;
SamplerParams.AdjustmentLag=10000;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;
SamplerParams.ScaleFactor=0.5;

%% Model
model = LogisticRegressionModel();
startParams=zeros(15,1);
%% Data
load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/LoigRegData.mat'));

%% Sampling method
proposalScheme = SimpMmalaProposal(1);
%proposalScheme = MalaProposal([1000,0;0,10],0.4);
%proposalScheme = RwmhProposal([10,0;0,10],1)

%% Set up the sampler

MCMCsampler = Sampler();

%% Sample!
rng('shuffle', 'twister')
minESS=zeros(10,1);
for i=1:10
    samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
    minESS(i)=min(CalculateESS(samples.params(5001:end,:),4999));
end
fprintf('Mean min ESS of 10 samples %.4f\n\n',mean(minESS))