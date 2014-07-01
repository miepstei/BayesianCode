%% Sampling parameters
clear all;
SamplerParams.Samples=4000;
SamplerParams.Burnin=2000;
SamplerParams.AdjustmentLag=100;
SamplerParams.NotifyEveryXSamples=50;
SamplerParams.LowerAcceptanceLimit=0.2;
SamplerParams.UpperAcceptanceLimit=0.5;
SamplerParams.ScaleFactor=0.5;

%% Model
model = TwoState_2param_AT();
startParams=[5000; 100];
%% Data
[data.bursts,data_description] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/two_state_20000.scn'}),2.5e-5,0.004);
data.tres = 0.000025;
data.concs = 1; %3e-8;
data.tcrit =0.004;
data.useChs=1;

%% Sampling method
proposalScheme = SimpMmalaProposal(0.1);
%proposalScheme = MalaProposal([1000,0;0,10],0.4);
%proposalScheme = RwmhProposal([10,0;0,10],1)

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
means = linspace(1,50000,100);
vars = linspace(1,500,100);
posterior=zeros(100,100);
for i=1:100
    for j=1:100
        posterior(i,j) = model.calcLogPosterior([means(i) vars(j)],data);
    end
    disp(i)
end
figure;contour(means,vars,posterior',linspace(mean(mean(posterior)),max(max(posterior)),10)); hold on; plot(samples.params(1:1000,1),samples.params(1:1000,2),'b.-');hold off