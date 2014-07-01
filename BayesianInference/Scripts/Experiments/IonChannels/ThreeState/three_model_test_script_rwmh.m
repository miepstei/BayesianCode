

%% Sampling parameters
clear all;
SamplerParams.Samples=200000;
SamplerParams.Burnin=100000;
SamplerParams.AdjustmentLag=1000;
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.3;
SamplerParams.ScaleFactor=0.5;

%% Model
model = ThreeState_4param_QET();
startParams=[1000;1000;1000;1000000];
%startParams=[50;669.29666761924;100;300];

%% Data

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [1e-6 1e-5 1e-4 1e-3];
data.tcrit =[1 1 1 1];
data.useChs=[0 0 1 1];

generativeParams=[1000;1000;1000;10^7]; %from Blue book
intervals=10000;

for i=1:length(data.concs)
    scnrec=generate_data(generativeParams,model,data.concs(i),intervals);
    fid = fopen(strcat(getenv('P_HOME'), '/BayesianInference/Data/dCK_', num2str(data.concs(i),'%.1e') , '.scn'),'w');
    DataController.write_scn_file(fid,scnrec);
end

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-06.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-05.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-04.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/dCK_1.0e-03.scn'}),data.tres(4),data.tcrit(4));

%% Max likelihood
options = optimset('fminsearch');
options.MaxIter=100000;
options.MaxFunEvals=100000;
[x,fval,exitflag] = fminsearch(@(params)-model.calcLogLikelihood(params,data),startParams,options);
fprintf('Max likelihood is %.4f, params %.4f %.4f %.4f %.4f\n',fval,x(1),x(2),x(3),x(4))

%% Sampling method
proposalScheme = RwmhProposal(eye(4,4),0);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
