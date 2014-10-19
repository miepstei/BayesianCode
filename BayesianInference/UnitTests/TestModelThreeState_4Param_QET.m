classdef TestModelThreeState_4Param_QET < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.model = ThreeState_4Param_QET();
            testCase.params=[1000; 1000;100;100];
            testCase.data.tres = 0.000025;
            testCase.data.concs = 1;
            testCase.data.tcrit = 0.004;
            [testCase.data.bursts,~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/two_state_20000.scn'}),testCase.data.tres,testCase.data.tcrit);
            testCase.data.useChs=1;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.model.kA,1);
            testCase.verifyEqual(testCase.model.h,0.01);
            testCase.verifyEqual(testCase.model.k,4);
            
            %check non-accessibilty
            try
                testCase.model.kA=1;
            catch ME
                testCase.verifyEqual(ME.identifier,'MATLAB:class:SetProhibited');                
            end

            try
                testCase.model.k=3;
            catch ME
                testCase.verifyEqual(ME.identifier,'MATLAB:class:SetProhibited');                
            end
            
            %check accessibilty
            testCase.model.h=0.1;
            testCase.verifyEqual(testCase.model.h,0.1);
        end
        
        %test Q generation
        function testQ(testCase)
            Q=testCase.model.generateQ(testCase.params,1);
            
            testCase.verifyEqual(Q(1,1),-1000);
            testCase.verifyEqual(Q(1,2),1000);
            testCase.verifyEqual(Q(1,3),0);
            testCase.verifyEqual(Q(2,1),1000);
            testCase.verifyEqual(Q(2,2),-1100);
            testCase.verifyEqual(Q(2,3),100);
            testCase.verifyEqual(Q(3,1),0);
            testCase.verifyEqual(Q(3,2),100);
            testCase.verifyEqual(Q(3,3),-100);            
        end
        
        function testLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([5000 100 100 100],testCase.data),55065.6868537701957393,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000 1000 100 100],testCase.data),47754.8280675098940264,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000 15 100 100],testCase.data),59184.9358063609033707,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([20000, 30 100 100],testCase.data),58860.1483657809003489,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),32047.9463194931558974,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[6.620499314783442;-9.635270892124939;46.769620851565008;-10.472768600431417],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[6.620499314783442;-9.635270892124939;46.769620851565008;-10.472768600431417],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:),[ 0.0068247520447574,0.0000307546392229,0.0009330568300948,-0.0003105537336265,0.0000307546392229,-0.0110831843333069,-0.0367878123705718,0.0122535423886616,0.0009330568300948,-0.0367878123705718,0.4038997521130320,0.0159752647725221,-0.0003105537336265,0.0122535423886616,0.0159752647725221,-0.0090753388883136]','AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(4,4))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),0)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior([-1 -1 -1 -1]),-Inf)
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior([5000 100,1000,1e9]),-64.472382573832277,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior([-1 -1 -1 -1]),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,[417022.0105323539464734;720324.4962389131542295;114.3848162011709064;3023325726.3253746032714844],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end