function sampleRun(i)
    %generate a run of 500 samples from the mMALA sampler to check
    %convergence
    
    %% Sampling parameters
    
    SamplerParams.Samples=50;
    SamplerParams.Burnin=50;
    SamplerParams.AdjustmentLag=5;
    SamplerParams.NotifyEveryXSamples=5;
    SamplerParams.LowerAcceptanceLimit=0.2;
    SamplerParams.UpperAcceptanceLimit=0.5;
    SamplerParams.ScaleFactor=0.5;

    %% Model
    model = TwoState_2param_QET();

    %% Data
    TRUE_PARAM_1=1000;
    TRUE_PARAM_2=10000000;
    PARAM_START=0:0.1:1.5;

    %randomly sample the start parameters
    %startParams=[18.3156;1.8316e+05];
    startParams=(exp([3,-2]).*[TRUE_PARAM_1,TRUE_PARAM_2])';
    fprintf('Start parameters %.2f,%.2f\n',startParams(1),startParams(2))
    
    data.tres = [ 0.000025 0.000025 0.000025 0.000025];
    data.concs = [10^-3 10^-4 10^-5 10^-6 ];
    data.tcrit =[1 1 1 1];
    data.useChs=[0 0 1 1];

    [data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
    [data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(2));
    [data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
    [data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

    %% Sampling method
    proposalScheme = SimpMmalaProposal(0.02);

    %% Set up the sampler
    MCMCsampler = Sampler();

    %% Sample!
    samples=MCMCsampler.blockSample(SamplerParams,model,data,proposalScheme,startParams);
    save(strcat(getenv('P_HOME'), '/BayesianInference/Results/TwoStateSampling/',num2str(i),'mMALA.mat'),'samples','SamplerParams')

end