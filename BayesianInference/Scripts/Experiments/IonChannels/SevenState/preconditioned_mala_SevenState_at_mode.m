%% truncated Mala
clear all;
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;
SamplerParams.AdjustmentLag=50;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

%% Model
model = SevenState_9param_QET();
startParams=[1896.83121431431 50309.6937905987 5942.08704691863 48.5522163518721 55881.1728863607 86.1441504249738 1512.36703897136 10068.081831692 381587176.53753]'; %mode

data.tres =  0.000025 ;
data.concs = 3e-8 ;
data.tcrit =0.0035;
data.useChs=1;

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),data.tres(1),data.tcrit(1));

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
samples=MCMCsampler.blockSample(SamplerParams,SevenState_9param_AT(),data,proposalScheme,startParams);
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/SevenState/mala_preconditioned_' ,num2str(t.Seed()), '_at_mode.mat'))