function samples=normal_test_script(proposalScheme,samplerScheme,startParams,steps,xlimit,ylimit)

    %NORMAL_TEST_SCRIPT Test script for mmala with normal target
    
    %INPUTS 
        %proposalScheme, Object of class Proposal
        %startParams, 2*1 vector of start parameters for the model
        
    %in the papers, proposal scheme takes the following form:   
    %proposalScheme = RwmhProposal(eye(2,2)*1,0.75);
    %proposalScheme = MalaProposal(eye(2,2)*1,0.75);
    %steps = 200
    %startParams=[5;40];
    
    %Figure 2:
    %steps=1000;
    %startParams=[15;2];
    
    %2011 paper
    
    %e.g. Fig 1: normal_test_script(SimpMmalaProposal(0.75^2),Sampler(),[5;40],200,[-10 10],[5 40])
    %     normal_test_script(MalaProposal(eye(2,2)*1,0.75^2),Sampler(),[5;40],200,[-10 10],[5 40])
    
    % Fig 2: normal_test_script(SimpMmalaProposal(0.2^2),Sampler(),[15;2],1000,[-15 15],[1 25])
    %        normal_test_script(MalaProposal(eye(2,2)*1,0.2^2),Sampler(),[15;2],1000,[-15 15],[1 25])
    
    %thesis
            %normal_test_script(SimpMmalaProposal(1),[2;2],50,[-3 3],[2 15])
            %normal_test_script(MalaProposal(eye(2,2)*1,0.005),[2;2],50,[-3 3],[2 15])
            
            %truncated adaption
            %normal_test_script(TruncatedMalaProposal(eye(2,2)*1,0.75^2,0.001),RosenthalAdaptiveSampler(),[5;40],5000,[-10 10],[5 40])
    
    SamplerParams.Samples=steps;
    SamplerParams.Burnin=0;
    SamplerParams.AdjustmentLag=100;
    SamplerParams.NotifyEveryXSamples=100;
    SamplerParams.LowerAcceptanceLimit=0.3;
    SamplerParams.UpperAcceptanceLimit=0.7;
    SamplerParams.ScaleFactor=0; %don't adjust the scaling

    load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/NormData30.mat'));

    MCMCsampler = samplerScheme;

    normModel=NormalModel();

    samples = MCMCsampler.blockSample(SamplerParams,normModel,data,proposalScheme,startParams);

    means = linspace(xlimit(1),xlimit(2),100);
    vars = linspace(ylimit(1),ylimit(2),100);
    posterior=zeros(100,100);
    for i=1:100
        for j=1:100
            posterior(i,j) = normModel.calcLogPosterior([means(i) vars(j)],data);
        end
    end
    figure;hold on;
    
    plot([startParams(1); samples.params(:,1)],[startParams(2); samples.params(:,2)],'b.-');
    contour(means,vars,posterior',50);
    xlim(xlimit);
    ylim(ylimit);
    hold off

end