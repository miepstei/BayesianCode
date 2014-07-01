%% Sampling parameters
clear all;
SamplerParams.Samples=100;
SamplerParams.Burnin=100;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=5;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;
SamplerParams.ScaleFactor=0.5;

%% Model
model = TwoState_2param_QET();
%startParams=[3669.29666761924;54739473.9172720];
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
proposalScheme = SimpMmalaProposalDecomp(10000000);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%%Plot likelihood surface and samples around true values
%use log scales -8 to 8

param_1 = linspace(-8,8,100);
param_2 = linspace(-8,8,100);
posterior=zeros(100,100);

for i=1:100
    for j=1:100
        posterior(i,j) = model.calcLogPosterior([exp(param_1(i))*TRUE_PARAM_1 exp(param_2(j))*TRUE_PARAM_2],data);
    end
    disp(i)
end
figure;contour(param_1,param_2,posterior',linspace(mean(mean(posterior)),max(max(posterior)),10)); hold on; plot(samples.params(1:end,1),samples.params(1:end,2),'b.-');hold off