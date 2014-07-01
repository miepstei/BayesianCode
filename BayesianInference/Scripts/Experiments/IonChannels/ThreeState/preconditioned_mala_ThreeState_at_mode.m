%% Sampling parameters
clear all;
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=100;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;
SamplerParams.ScaleFactor=0.1;

%% Model
model = ThreeState_4param_QET();
startParams=[100;100;50;100000]; %sample from ML mode

%% Data

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [1e-6 1e-5 1e-4 1e-3 ];
data.tcrit =[1 1 1 1];
data.useChs=[0 0 1 1];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-06.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-05.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-04.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-03.scn'}),data.tres(4),data.tcrit(4));

%%Determine MLE and hessian
options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f %.4f %.4f\n',fval,x(1),x(2),x(3),x(4))
hessian = (model.calcMetricTensor([x(1);x(2);x(3);x(4)],data))^-1;
startParams=[x(1);x(2);x(3);x(4)];

%% Sampling method
proposalScheme = MalaProposal(hessian,0.01);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,ThreeState_4param_AT(),data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/ThreeState/mala_preconditioned_at_mode_' ,num2str(t.Seed()), '.mat'))