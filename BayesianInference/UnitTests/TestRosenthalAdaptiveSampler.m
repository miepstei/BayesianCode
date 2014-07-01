classdef TestRosenthalAdaptiveSampler < matlab.unittest.TestCase
    
    properties
        normal
        blr
        sampler
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            %normal test case parameters
            testCase.normal.model = NormalModel();       
            a=load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/NormData.mat'));
            testCase.normal.startParams=[2; 10];  
            testCase.normal.data=a.data;
            testCase.normal.rwmhProposalScheme = RwmhMixtureProposal(eye(2,2),0);
            testCase.normal.malaProposalScheme = MalaProposal(eye(2,2),1);         
            testCase.normal.SamplerParams.Samples=1000;
            testCase.normal.SamplerParams.Burnin=500;
            testCase.normal.SamplerParams.AdjustmentLag=50;
            testCase.normal.SamplerParams.NotifyEveryXSamples=1000;
            testCase.normal.SamplerParams.LowerAcceptanceLimit=0.3;
            testCase.normal.SamplerParams.UpperAcceptanceLimit=0.7;
            testCase.normal.SamplerParams.ScaleFactor=0.1;            
            
            %Sampler to be tested
            testCase.sampler = RosenthalAdaptiveSampler();
        end
    end    

    methods(Test)
        function testRwmhSamples(testCase)
            normalTestCase = testCase.normal;
            rng(1)
            testSamples = testCase.sampler.blockSample(normalTestCase.SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.rwmhProposalScheme,normalTestCase.startParams);
            %check samples, posteriors
            load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/RosenthalAdaptionSamplerRWMH.mat'));
            
            testCase.assertEqual(testSamples.N,samples.N);
            testCase.assertEqual(testSamples.params,samples.params,'AbsTol', 1e-6)
            testCase.assertEqual(testSamples.acceptances,samples.acceptances)
            testCase.assertEqual(testSamples.posteriors,samples.posteriors,'AbsTol', 1e-6)
            testCase.assertEqual(testSamples.proposals,samples.proposals,'AbsTol', 1e-6)
            
            fprintf('Runtime for rwmh sampling from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')
        end    
         function testSamplerAdjustment(testCase)
            normalTestCase = testCase.normal;
            SamplerParams = testCase.normal.SamplerParams;
            SamplerParams.Samples=2000;
            SamplerParams.Burnin=1000;
            SamplerParams.AdjustmentLag=100;
            SamplerParams.NotifyEveryXSamples=2000;
            rng(1)
            samples = testCase.sampler.blockSample(SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.rwmhProposalScheme,normalTestCase.startParams);
           
            %should be one adjustment
            testCase.assertEqual(samples.scaleFactors(end),1);
            fprintf('Runtime for rwmh shortening adjustment from Normal Model is %.4f\n', samples.sampleTime)
            
            %test the adjustment lengthens the scale factor
            SamplerParams.LowerAcceptanceLimit=0.01;
            SamplerParams.UpperAcceptanceLimit=0.1;
            rng(1)
            samples  = testCase.sampler.blockSample(SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.rwmhProposalScheme,normalTestCase.startParams);
            testCase.assertEqual(samples.scaleFactors(end),2.593742460100002,'AbsTol', 1e-6);
            fprintf('Runtime for rwmh lengthening adjustment from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')
        end       
        
        function testMalaSamples(testCase)
            normalTestCase = testCase.normal;
            rng(1)
            testSamples = testCase.sampler.blockSample(normalTestCase.SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.malaProposalScheme,normalTestCase.startParams);
            load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/RosenthalAdaptionSamplerMALA.mat'));
            testCase.assertEqual(testSamples.N,1000);
            testCase.assertEqual(testSamples.params,samples.params,'AbsTol', 1e-6)
            testCase.assertEqual(testSamples.acceptances,samples.acceptances)
            testCase.assertEqual(testSamples.posteriors,samples.posteriors,'AbsTol', 1e-6)
            testCase.assertEqual(testSamples.proposals,samples.proposals,'AbsTol', 1e-6)            
            fprintf('Runtime for mala sampling from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')
        end     
    end
end