%% truncated Mala
clear all;
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = SevenState_10Param_QET();

%guess2
startParams=[1500 50000 2000 20 80000 300 1e8 1000 20000 1e8]'; %guess 2

data.tres =  [0.000025 0.000025];
data.concs = [3e-8 0.00001];
data.tcrit =[0.0035 0.005];
data.useChs=[1 0];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/HighConc/20000/data_3.scn'}),data.tres(2),data.tcrit(2));

%%Determine MLE and hessian

options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f ... \n',fval,x(1),x(2))
hessian = (model.calcMetricTensor(x,data))^-1;
startParams=x;

%% Sampling method
proposalScheme = MalaProposal(hessian,0.01);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,SevenState_10Param_AT(),data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/10param/mala_preconditioned_' ,num2str(t.Seed()), '_at_mode.mat'))