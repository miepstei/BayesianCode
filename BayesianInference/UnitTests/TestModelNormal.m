classdef TestModelNormal < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.model = NormalModel();
            testCase.params=[0 10];
            a=load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/NormData.mat'));
            testCase.data = a.data;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.model.k,2);
            
            %check non-accessibilty

            try
                testCase.model.k=3;
            catch ME
                testCase.verifyEqual(ME.identifier,'MATLAB:class:SetProhibited');                
            end

        end
        
        function testLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([0 10],testCase.data),-1.1101343989673376e+03,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([-5 1],testCase.data),-1.8000665893344027e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1 -5],testCase.data),NaN,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([10, 15],testCase.data),-1.2221109521389603e+03,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),-1.1184284486074396e+03,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[-7.8549355477933291e-01;-1.2645377784554128e+00],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[-7.8549355477933291e-01;-1.2645377784554128e+00],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcMetricTensor(testCase.params,testCase.data),[ 3 0 ; 0 6],'AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(2,2))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),[0; 0])
            testCase.verifyEqual(testCase.model.calcDerivLogPrior([-1 -1]),[0; -Inf])
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior([0 10]),-8.294049640102028,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior([-1 -1]),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,[-3.319119811897040;72.032449344215806],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase
        end
    end    
    
end
