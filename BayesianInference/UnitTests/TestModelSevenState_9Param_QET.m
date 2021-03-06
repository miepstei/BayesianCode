classdef TestModelSevenState_9Param_QET < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            testCase.model = SevenState_9Param_QET();
            testCase.params=[1500,50000,13000,50,15000,10,6000,5000,100000000]';
            testCase.data.tres = 0.000025;
            testCase.data.concs = 3e-8;
            testCase.data.tcrit = 0.0035;
            [testCase.data.bursts,~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/20000/test_1.scn'}),testCase.data.tres,testCase.data.tcrit);
            testCase.data.useChs=1;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.model.kA,3);
            testCase.verifyEqual(testCase.model.h,0.01);
            testCase.verifyEqual(testCase.model.k,9);
            
            %check non-accessibilty
            try
                testCase.model.kA=3;
            catch ME
                testCase.verifyEqual(ME.identifier,'MATLAB:class:SetProhibited');                
            end

            try
                testCase.model.k=4;
            catch ME
                testCase.verifyEqual(ME.identifier,'MATLAB:class:SetProhibited');                
            end
            
            %check accessibilty
            testCase.model.h=0.1;
            testCase.verifyEqual(testCase.model.h,0.1);
            testCase.model.h=0.01;
            testCase.verifyEqual(testCase.model.h,0.01);
        end
        
        %test Q generation
        function testQ(testCase)
            Q=testCase.model.generateQ(testCase.params,1);
            %from 2003 blue book
            testCaseQ=[-1500.0000000000 0.0000000000 0.0000000000 50000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -13000.0000000000 0.0000000000 0.0000000000 50.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -15000.0000000000 0.0000000000 0.0000000000 10.0000000000 0.0000000000 1500.0000000000 0.0000000000 0.0000000000 -61000.0000000000 100000000.0000000000 100000000.0000000000 0.0000000000 0.0000000000 13000.0000000000 0.0000000000 5000.0000000000 -100006050.0000000000 0.0000000000 100000000.0000000000 0.0000000000 0.0000000000 15000.0000000000 6000.0000000000 0.0000000000 -100005010.0000000000 100000000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 6000.0000000000 5000.0000000000 -200000000.0000000000 ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-10);
            
            Q=testCase.model.generateQ(testCase.params,0.01);
            testCaseQ=[-1500.0000000000 0.0000000000 0.0000000000 50000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -13000.0000000000 0.0000000000 0.0000000000 50.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -15000.0000000000 0.0000000000 0.0000000000 10.0000000000 0.0000000000 1500.0000000000 0.0000000000 0.0000000000 -61000.0000000000 1000000.0000000000 1000000.0000000000 0.0000000000 0.0000000000 13000.0000000000 0.0000000000 5000.0000000000 -1006050.0000000000 0.0000000000 1000000.0000000000 0.0000000000 0.0000000000 15000.0000000000 6000.0000000000 0.0000000000 -1005010.0000000000 1000000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 6000.0000000000 5000.0000000000 -2000000.0000000000 ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-10);
            
            params2=[1500,50000,12000,50,14000,10,6000,5000,200000000];
            Q=testCase.model.generateQ(params2,0.00001);
            testCaseQ=[-1500.0000000000 0.0000000000 0.0000000000 50000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -12000.0000000000 0.0000000000 0.0000000000 50.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 -14000.0000000000 0.0000000000 0.0000000000 10.0000000000 0.0000000000 1500.0000000000 0.0000000000 0.0000000000 -61000.0000000000 2000.0000000000 1000.0000000000 0.0000000000 0.0000000000 12000.0000000000 0.0000000000 5000.0000000000 -8050.0000000000 0.0000000000 1000.0000000000 0.0000000000 0.0000000000 14000.0000000000 6000.0000000000 0.0000000000 -6010.0000000000 2000.0000000000 0.0000000000 0.0000000000 0.0000000000 0.0000000000 6000.0000000000 5000.0000000000 -3000.0000000000  ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-10);            
            
        end
        
        function testLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),3.905394943748901e+04,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000,50000,13000,50,15000,10,6000,5000,150000000],testCase.data),3.348462720909426e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1500,50000,18000,50,15700,17,4000,5000,100000000],testCase.data),3.848835872822455e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([150,5000,130000,500,1500,10,8000,7000,50000000],testCase.data),3.462030052129648e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),3.892039950217535e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:),[0.0006100966366455,-0.0000133062807132,-0.0000186504651421,0.0013712629622322,-0.0000021011703560,0.0008287753998210,0.0000030864364348,0.0000157519380629,-0.0000000006344363,-0.0000133062807132,0.0000005173964590,0.0000003645588906,-0.0000510918249635,0.0000000438955811,-0.0000435328663236,-0.0000000174818641,-0.0000004620365863,0.0000000000232184,-0.0000186504651421,0.0000003645588906,-0.0000017020905549,0.0006452034124856,0.0000046417521569,-0.0004553287630557,-0.0000058100777478,0.0000024157414240,-0.0000000003134858,0.0013712629622322,-0.0000510918249635,0.0006452034124856,0.0108680338579591,-0.0001846500111215,-0.0461942474870390,-0.0001800739715626,0.0006815575710876,-0.0000000481350716,-0.0000021011703560,0.0000000438955811,0.0000046417521569,-0.0001846500111215,-0.0000036642394101,0.0011449058019677,0.0000018199151938,-0.0000026206459945,0.0000000000863180,0.0008287753998210,-0.0000435328663236,-0.0004553287630557,-0.0461942474870390,0.0011449058019677,-0.1278640962149538,0.0005878255916941,-0.0003978424535927,0.0000000308489459,0.0000030864364348,-0.0000000174818641,-0.0000058100777478,-0.0001800739715626,0.0000018199151938,0.0005878255916941,0.0000006018600599,0.0000100059626675,0.0000000001085709,0.0000157519380629,-0.0000004620365863,0.0000024157414240,0.0006815575710876,-0.0000026206459945,-0.0003978424535927,0.0000100059626675,-0.0000002460033406,-0.0000000004024682,-0.0000000006344363,0.0000000000232184,-0.0000000003134858,-0.0000000481350716,0.0000000000863180,0.0000000308489459,0.0000000001085709,-0.0000000004024682,0.0000000000000534]','AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(9,9))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),0)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1]),-Inf)
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior(testCase.params),-1.335499353136537e+02,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1]),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,1.0e+09 * [0.000417022010532;0.000720324496239;0.000000114384816;0.000302332579609;0.000146755899350;0.000092338603845;0.000186260219515;0.000345560733587;3.967674742312732],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end