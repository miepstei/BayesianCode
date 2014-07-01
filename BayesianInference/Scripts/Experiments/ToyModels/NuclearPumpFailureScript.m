%% Sampling parameters
clear all;
SamplerParams.Samples=20000;
SamplerParams.Burnin=10;
SamplerParams.AdjustmentLag=10;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.gamma=10;
SamplerParams.Tau=0.5;

%guess my epsilon
epsilon=10;

model=NuclearPumpModel();

load(strcat(getenv('P_HOME'), '/BayesianInference/Data/nuclearPumpData.mat'));

%startParams=[1;0.0530110262934690;0.0636132315521629;0.0795165394402036;0.111323155216285;0.572519083969466;0.604325699745547;0.952380952380952;0.952380952380952;1.90476190476190;2.09923664122137];
startParams=[1;repmat(0.1,10,1)];
proposalScheme = MalaProposal(eye(11,11),epsilon);

%% Set up the sampler
MCMCsampler = AdaptiveSampler();

truncated_mala_samples=MCMCsampler.blockSample(SamplerParams,model,nuclearPumpData,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/NuclearMalaAdaption.mat'),'truncated_mala_samples','SamplerParams')