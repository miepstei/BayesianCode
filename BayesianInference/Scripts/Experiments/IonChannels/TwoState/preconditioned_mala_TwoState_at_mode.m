%% truncated Mala
clear all;
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=100;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = TwoState_2param_QET();

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

%%Determine MLE and hessian
startParams=[100;547394.9172720];
options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f\n',fval,x(1),x(2))
hessian = (model.calcMetricTensor([x(1);x(2)],data))^-1;
startParams=[x(1);x(2)];

%% Sampling method
proposalScheme = MalaProposal(hessian,0.01);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,TwoState_2param_AT(),data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/TwoState/mala_preconditioned_' ,num2str(t.Seed()), '_at_mode.mat'))