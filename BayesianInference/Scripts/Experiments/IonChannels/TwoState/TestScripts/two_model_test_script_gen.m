%% Sampling parameters
clear all;
SamplerParams.Samples=500;
SamplerParams.Burnin=500;
SamplerParams.AdjustmentLag=100;
SamplerParams.NotifyEveryXSamples=100;
SamplerParams.LowerAcceptanceLimit=0.2;
SamplerParams.UpperAcceptanceLimit=0.5;
SamplerParams.ScaleFactor=0.5;

%% Model
model = TwoState_2param_AT();
startParams=[274.7346; 0.2747];
%startParams=[5000; 150];
TRUE_PARAM_1=15000;
TRUE_PARAM_2=15;

%% Data
data.tres = 0.000025;
data.concs = 1; %3e-8;
data.tcrit =0.004;
data.useChs=1;

%data generated with [alpha=15000,beta=15]
[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/two_state_20000.scn'}),data.tres(1),data.tcrit(1));

%% Sampling method
proposalScheme = SimpMmalaProposal(0.01);
%proposalScheme = MalaProposal([1000,0;0,10],0.1);
%proposalScheme = RwmhProposal([10,0;0,10],1)

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);

%shortcut for example
load(strcat(getenv('P_HOME'), '/BayesianInference/Results/Surfaces/saved_posterior.mat'))

% means = linspace(-8,8,100);
% vars = linspace(-8,8,100);
% posterior=zeros(100,100);

% for i=1:100
%     for j=1:100
%         posterior(i,j) = model.calcLogPosterior([exp(means(i))*TRUE_PARAM_1 exp(vars(j))*TRUE_PARAM_2],data);
%     end
%     disp(i)
% end
% posterior(posterior==-Inf)=min(min(posterior(posterior~=-Inf)));
figure;contour(means,vars,posterior',linspace(mean(mean(posterior)),max(max(posterior)),100)); hold on; plot(log(samples.params(1:end,1)/TRUE_PARAM_1),log(samples.params(1:end,2)/TRUE_PARAM_2),'b.-');hold off