classdef TestSampler < matlab.unittest.TestCase
    
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
            testCase.normal.rwmhProposalScheme = RwmhProposal(eye(2,2),0);
            testCase.normal.malaProposalScheme = MalaProposal(eye(2,2),1);
            testCase.normal.mmalaProposalScheme = SimpMmalaProposal(1);             
            testCase.normal.SamplerParams.Samples=10;
            testCase.normal.SamplerParams.Burnin=5;
            testCase.normal.SamplerParams.AdjustmentLag=5;
            testCase.normal.SamplerParams.NotifyEveryXSamples=10;
            testCase.normal.SamplerParams.LowerAcceptanceLimit=0.3;
            testCase.normal.SamplerParams.UpperAcceptanceLimit=0.7;
            testCase.normal.SamplerParams.ScaleFactor=0.5;            
            
            %blr test case parameters
            testCase.blr.model = LogisticRegressionModel();
            
            %Australian credit data 
            a=load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/LoigRegData.mat'));
            testCase.blr.data = a.data;   
            testCase.blr.startParams = zeros(15,1);
            
            %epsilon = scaleFactor * D^1/2 for burnin, scaleFactor * D^1/3
            %for sampling
            %for BC code
            testCase.blr.malaProposalScheme = MalaProposal(eye(testCase.blr.model.k,testCase.blr.model.k),0.0103279555898864);
            testCase.blr.mmalaProposalScheme = SimpMmalaProposal(1);
            testCase.blr.rwmhProposalScheme = RwmhProposal(eye(testCase.blr.model.k,testCase.blr.model.k),1);
            testCase.blr.SamplerParams.Samples=10000;
            testCase.blr.SamplerParams.Burnin=5000;
            testCase.blr.SamplerParams.AdjustmentLag=10000;
            testCase.blr.SamplerParams.NotifyEveryXSamples=10000;  
            testCase.blr.SamplerParams.LowerAcceptanceLimit=0.2;
            testCase.blr.SamplerParams.UpperAcceptanceLimit=0.5;
            testCase.blr.SamplerParams.ScaleFactor=0.2;
            
            %Sampler to be tested
            testCase.sampler = Sampler();
        end
    end
    
    methods(Test)
        function testRwmhSamples(testCase)
            normalTestCase = testCase.normal;
            rng(1)
            samples = testCase.sampler.blockSample(normalTestCase.SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.rwmhProposalScheme,normalTestCase.startParams);
            %check samples, likelihoods  
            
            testCase.assertEqual(samples.N,10);
            testCase.assertEqual(samples.params,[1.3509862348087593 11.1811660419655325;-0.1950727276889210 10.4227127446818404;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;-1.3046857661904432 9.5771615046740433;],'AbsTol', 1e-6)
            testCase.assertEqual(samples.acceptances,[1 1 1 0 0 0 0 0 0 0]')
            testCase.assertEqual(samples.posteriors,1.0e+03 *[-1.126208401540793 -1.119342737270585   -1.120100708122708  -1.120100708122708 -1.120100708122708  -1.120100708122708 -1.120100708122708 -1.120100708122708 -1.120100708122708 -1.120100708122708]','AbsTol', 1e-6)
            testCase.assertEqual(samples.proposals,[1.3509862348087593 11.1811660419655325;-0.1950727276889210 10.4227127446818404;-1.3046857661904432 9.5771615046740433;-1.8633665306644147 9.7555417305238095;-0.7182431445233743 8.7252745350515735;-2.8140904909248361 10.4530356525085750;-1.1378723267369406 7.6117427953912635;-0.1295145007274261 11.6063216894238046;-0.7010273203646284 11.3584133979165447;-3.1698083407210742 8.5260544454334557;],'AbsTol', 1e-6)
            
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
            testCase.assertEqual(samples.scaleFactors(end),0.5);
            fprintf('Runtime for rwmh shortening adjustment from Normal Model is %.4f\n', samples.sampleTime)
            
            %test the adjustment lengthens the scale factor
            SamplerParams.LowerAcceptanceLimit=0.01;
            SamplerParams.UpperAcceptanceLimit=0.1;
            rng(1)
            samples = testCase.sampler.blockSample(SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.rwmhProposalScheme,normalTestCase.startParams);
            testCase.assertEqual(samples.scaleFactors(end),5.0625);
            fprintf('Runtime for rwmh lengthening adjustment from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')
        end       
        
        function testMalaSamples(testCase)
            normalTestCase = testCase.normal;
            rng(1)
            samples = testCase.sampler.blockSample(normalTestCase.SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.malaProposalScheme,normalTestCase.startParams);
            testCase.assertEqual(samples.N,10);
            testCase.assertEqual(samples.params,[-2.0417605425809047 11.3059958636936884;-2.0417605425809047 11.3059958636936884;-2.0417605425809047 11.3059958636936884;-2.0417605425809047 11.3059958636936884;-0.8049460016181552 9.1024581641773405;-0.8049460016181552 9.1024581641773405;0.3451209964211807 9.7537586785336483;0.3451209964211807 9.7537586785336483;0.3451209964211807 9.7537586785336483;0.3451209964211807 9.7537586785336483;],'AbsTol', 1e-6)
            testCase.assertEqual(samples.acceptances,[1 0 0 0 1 0 1 0 0 0]')
            testCase.assertEqual(samples.posteriors,1.0e+03 *[-1.127613956571376 -1.127613956571376 -1.127613956571376 -1.127613956571376 -1.120357538354997 -1.120357538354997 -1.118767550545597 -1.118767550545597 -1.118767550545597 -1.118767550545597]','AbsTol', 1e-6)
            testCase.assertEqual(samples.proposals,[-2.0417605425809047 11.3059958636936884;-1.4991179944933666 7.5436841570918256;-0.7986102720034829 7.7294725879175665;0.2253211938540803 8.1052760078995743;-0.8049460016181552 9.1024581641773405;-1.3310971677667149 12.5950515356509598;0.3451209964211807 9.7537586785336483;-1.8819278873689738 11.0823196401879027;-0.8870137354061238 10.5108068205506999;1.1618018315957206 8.0420258001942546;],'AbsTol', 1e-6)            
            fprintf('Runtime for mala sampling from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')
        end    
        
        function testMmalaSamples(testCase)
            normalTestCase = testCase.normal;
            rng(1)
            samples = testCase.sampler.blockSample(normalTestCase.SamplerParams,normalTestCase.model,normalTestCase.data,normalTestCase.mmalaProposalScheme,normalTestCase.startParams);
            testCase.assertEqual(samples.N,10);
            testCase.assertEqual(samples.params, [0.494376135495843  10.503013987674422;-0.343647381312903   9.693393992601461;-0.775950650506329   9.512193425138124;-0.420926862384521   9.580265623079244; -0.017007702461311   9.350422899128464; -1.198605596618170  10.094623994644612;-0.376953737101506   8.905447705574394; 0.449405563945050  10.500515748821083; -0.288325860716995  10.316096098044380; 1.030893857976648  10.841827162081820],'AbsTol', 1e-6)
            
            testCase.assertEqual(samples.acceptances,[1 1 1 1 1 1 1 1 1 1]')
            testCase.assertEqual(samples.posteriors,1.0e+03 *[-1.120403422277143 -1.118220442388225 -1.118863844310509 -1.118359328029760 -1.118920638366792 -1.119763712892767 -1.121035960873866  -1.120304587715612 -1.118998948420850  -1.123275659991553]','AbsTol', 1e-6)
            testCase.assertEqual(samples.proposals,[0.494376135495843  10.503013987674422; -0.343647381312903   9.693393992601461; -0.775950650506329   9.512193425138124;  -0.420926862384521   9.580265623079244; -0.017007702461311   9.350422899128464; -1.198605596618170  10.094623994644612; -0.376953737101506   8.905447705574394; 0.449405563945050  10.500515748821083;-0.288325860716995  10.316096098044380;1.030893857976648  10.841827162081820],'AbsTol', 1e-6)            
            fprintf('Runtime for mmala sampling from Normal Model is %.4f\n', samples.sampleTime)
            rng('shuffle', 'twister')            
        end
        
        function testRwmhSamplesBLR(testCase)
            blrTestCase = testCase.blr;
            rng(1)            
            samples = testCase.sampler.cwSample(blrTestCase.SamplerParams,blrTestCase.model,blrTestCase.data,blrTestCase.rwmhProposalScheme,blrTestCase.startParams);
            load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/Calderhead_BLR_RWMH.mat'));
            fprintf('Runtime for Rwmh sampling from Bayesian Logistic Regression is %.4f\n', samples.sampleTime)
            testCase.assertEqual(samples.params(5001:end,:),betaPosterior,'AbsTol', 1e-12);            
            testCase.assertEqual(samples.N,10000);
            
            rng('shuffle', 'twister') 
        end
        
        function testMmalaSamplesBLR(testCase)
            blrTestCase = testCase.blr;
            rng(1)
            samples = testCase.sampler.blockSample(blrTestCase.SamplerParams,blrTestCase.model,blrTestCase.data,blrTestCase.mmalaProposalScheme,blrTestCase.startParams);
            load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/Calderhead_BLR_mMALA.mat'));
            fprintf('Runtime for mMALA sampling from Bayesian Logistic Regression Model is %.4f\n', samples.sampleTime)
            testCase.assertEqual(samples.params(5001:end,:),betaPosterior,'AbsTol', 1e-12);
            testCase.assertEqual(samples.N,10000);
            rng('shuffle', 'twister') 
        end
        
        function testMalaSamplesBLR(testCase)
            blrTestCase = testCase.blr;
            rng(1)
            samples = testCase.sampler.blockSample(blrTestCase.SamplerParams,blrTestCase.model,blrTestCase.data,blrTestCase.malaProposalScheme,blrTestCase.startParams);
            load(strcat(getenv('P_HOME') , '/BayesianInference/UnitTests/TestData/Calderhead_BLR_MALA.mat'));
            fprintf('Runtime for MALA sampling from Bayesian Logistic Regression is %.4f\n', samples.sampleTime)
            testCase.assertEqual(samples.params(5001:end,:),betaPosterior,'AbsTol', 1e-12);
            testCase.assertEqual(samples.N,10000);            
            rng('shuffle', 'twister')             
        end
        
    end

end