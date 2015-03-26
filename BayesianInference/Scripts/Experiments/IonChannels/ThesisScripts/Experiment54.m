%%Experiment 54
% SAMPLER:  Log RWMH -> Adaptive MCMC at mode -> MALA
% NUMBER OF CHAINS: Single Chain
% MODEL: Three State 4-params from Colquhoun2003
% DATASET: 3-concentrations, synthetic data from Experiment 44
% one channel
% SAMPLER: Standard -> Adaptive -> Standard

fprintf('\n**** SAMPLING STARTING ****\n');

clear all;
experiment_description='Log RWMH -> Adaptive MCMC at mode -> MALA , Single Chain, 3-state 4-params concentration dependent, 3-concentrations, synthetic data from Experiment 44';

%% sampling parameters
SamplerParams.Samples=50000;
SamplerParams.Burnin=25000;
SamplerParams.AdjustmentLag=50; 
SamplerParams.NotifyEveryXSamples=1000;
SamplerParams.ScaleFactor=0.1;
SamplerParams.LowerAcceptanceLimit=0.1;
SamplerParams.UpperAcceptanceLimit=0.5;

%% RWMH Starting Parameters
startParams = [1000,1000,100,100]'; 
clearvars -except experiment_description SamplerParams model startParams SamplerParams

%% Data
load(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment44_1206427105.mat'),'data');

%% Sampling method - redefine model
model = ThreeState_4Param_AT();
proposalScheme = LogRwmhProposal(eye(model.k,model.k),1);

%% Set up the sampler
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
fprintf('\n**** MAP ESTIMATION STARTING ****\n');
samples=MCMCsampler.cwSample(SamplerParams,model,data,proposalScheme,startParams);

%% Save the data
savedir = strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Synthetic');
if ~isequal(exist(savedir, 'dir'),7)
    mkdir(savedir)
end
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Synthetic/Experiment54_',class(proposalScheme), '_' , num2str(t.Seed) , '.mat'))

%find the maximum from the previous sampling
[MAP,idx] = max(samples.posteriors(:));
[row,col] = ind2sub(size(samples.posteriors),idx);

%we need the 1:col sampled parameters from the row, and the previous
%col+1:model.k params from the PREVIOUS row for the parameters
%corresponding to the MAP

mapStartParams = [samples.params(row,1:col),samples.params(row-1,col+1:end)]';
clearvars -except mapStartParams proposalScheme data model SamplerParams MAP
fprintf('\n**** MAP ESTIMATION COMPLETED ****\n')
mapString = strcat(sprintf('%.4f, ',mapStartParams),' MAP estimate = ',sprintf('%.4f',MAP));
fprintf('\n**** MAP ESTIMATION COMPLETED: %s****\n',mapString)

%% Adaptive sampling parameters
SamplerParams.Samples=100000;
SamplerParams.Burnin=50000;

proposalScheme = RwmhMixtureProposal(eye(model.k,model.k),0);
MCMCsampler = RosenthalAdaptiveSampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,mapStartParams);

%% Save the data
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Synthetic/Experiment54_',class(proposalScheme), '_' , num2str(t.Seed) , '.mat'))

covarianceEstimate = samples.covariance(:,:,end);
fprintf('\n**** COVARIANCE ESTIMATION COMPLETED ****\n')

%% MALA sampling params
clearvars -except mapStartParams proposalScheme data model covarianceEstimate SamplerParams

%% MALA sampling parameters
SamplerParams.Samples=20000;
SamplerParams.Burnin=10000;

SamplerParams.LowerAcceptanceLimit=0.3;
SamplerParams.UpperAcceptanceLimit=0.7;

proposalScheme = MalaProposal(covarianceEstimate,0.1);
MCMCsampler = Sampler();

%% Sample!
rng('shuffle')
t=rng;
samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,mapStartParams);

%% Save the data
save(strcat(getenv('P_HOME'), '/BayesianInference/Results/Thesis/Synthetic/Experiment54_',class(proposalScheme), '_' , num2str(t.Seed) , '.mat'))
fprintf('\n**** MALA SAMPLES COMPLETED ****\n')
fprintf('\n**** SAMPLING COMPLETED ****\n')

