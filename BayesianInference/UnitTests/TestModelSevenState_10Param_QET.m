classdef TestModelSevenState_10Param_QET < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            testCase.model = SevenState_10Param_AT();
            testCase.params=[1500 50000 2000 20 80000 300 1e8 1000 20000 1e8]'; %guess2 rate constants
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
            testCase.verifyEqual(testCase.model.k,10);
            
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
            testCaseQ=[-1500.0000000000,0.0000000000,0.0000000000,50000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-2000.0000000000,0.0000000000,0.0000000000,20.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-80000.0000000000,0.0000000000,0.0000000000,300.0000000000,0.0000000000,1500.0000000000,0.0000000000,0.0000000000,-71000.0000000000,100000000.0000000000,100000000.0000000000,0.0000000000,0.0000000000,2000.0000000000,0.0000000000,20000.0000000000,-100001020.0000000000,0.0000000000,100000000.0000000000,0.0000000000,0.0000000000,80000.0000000000,1000.0000000000,0.0000000000,-100020300.0000000000,100000000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,1000.0000000000,20000.0000000000,-200000000.0000000000 ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-6);
            
            Q=testCase.model.generateQ(testCase.params,0.01);
            testCaseQ=[-1500.0000000000,0.0000000000,0.0000000000,50000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-2000.0000000000,0.0000000000,0.0000000000,20.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-80000.0000000000,0.0000000000,0.0000000000,300.0000000000,0.0000000000,1500.0000000000,0.0000000000,0.0000000000,-71000.0000000000,1000000.0000000000,1000000.0000000000,0.0000000000,0.0000000000,2000.0000000000,0.0000000000,20000.0000000000,-1001020.0000000000,0.0000000000,1000000.0000000000,0.0000000000,0.0000000000,80000.0000000000,1000.0000000000,0.0000000000,-1020300.0000000000,1000000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,1000.0000000000,20000.0000000000,-2000000.0000000000 ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-10);
            
            params2=[1500,50000,12000,50,14000,10,100000000,6000,5000,200000000];
            Q=testCase.model.generateQ(params2,0.00001);
            testCaseQ=[-1500.0000000000,0.0000000000,0.0000000000,50000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-12000.0000000000,0.0000000000,0.0000000000,50.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,-14000.0000000000,0.0000000000,0.0000000000,10.0000000000,0.0000000000,1500.0000000000,0.0000000000,0.0000000000,-61000.0000000000,2000.0000000000,1000.0000000000,0.0000000000,0.0000000000,12000.0000000000,0.0000000000,5000.0000000000,-8050.0000000000,0.0000000000,1000.0000000000,0.0000000000,0.0000000000,14000.0000000000,6000.0000000000,0.0000000000,-6010.0000000000,2000.0000000000,0.0000000000,0.0000000000,0.0000000000,0.0000000000,6000.0000000000,5000.0000000000,-3000.0000000000  ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-10);            
            
        end
        
        function testLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),3.858686121486090e+04,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000,50000,13000,50,15000,10,150000000,6000,5000,150000000],testCase.data),3.355036228698904e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1500,50000,18000,50,15700,17,2e8,4000,5000,100000000],testCase.data),3.852808259951792e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([150,5000,130000,500,1500,10,2e8,8000,7000,50000000],testCase.data),3.349705432531993e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),3.835660270556150e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[0.0502033959,-0.0031219835,0.7965062701,-21.7464322352,-0.0100080517,1.2337043314,-0.0000036976,0.3320706364,-0.0429269316,0.0000048745 ]','AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[0.0502033959,-0.0031219835,0.7965062701,-21.7464322352,-0.0100080517,1.2337043314,-0.0000036976,0.3320706364,-0.0429269316,0.0000048745 ]','AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:),[0.0004564936,-0.0000105501,0.0000374348,0.0030011142,-0.0000004547,0.0000178625,-0.0000000000,0.0000101136,0.0000087857,-0.0000000546,-0.0000105501,0.0000003638,-0.0000012005,-0.0001389890,-0.0000005275,-0.0000009641,-0.0000002910,0.0000002910,0.0000001091,-0.0000002365,0.0000374348,-0.0000012005,0.0005617039,-0.0055767487,-0.0000041655,0.0004684989,0.0000002001,0.0001356420,-0.0000060390,0.0000009095,0.0030011142,-0.0001389890,-0.0055767487,-0.4865666415,-0.0000789805,-0.0020849257,0.0000001091,-0.0034919140,0.0003026071,0.0000003092,-0.0000004547,-0.0000005275,-0.0000041655,-0.0000789805,0.0000028376,0.0000036016,0.0000000909,0.0000012551,0.0000004002,-0.0000004184,0.0000178625,-0.0000009641,0.0004684989,-0.0020849257,0.0000036016,0.0044949411,-0.0000002001,0.0001298940,-0.0000034561,0.0000006730,-0.0000000000,-0.0000002910,0.0000002001,0.0000001091,0.0000000909,-0.0000002001,0.0000042201,0.0000001091,-0.0000004729,-0.0000001091,0.0000101136,0.0000002910,0.0001356420,-0.0034919140,0.0000012551,0.0001298940,0.0000001091,0.0004962931,-0.0000000182,0.0000001273,0.0000087857,0.0000001091,-0.0000060390,0.0003026071,0.0000004002,-0.0000034561,-0.0000004729,-0.0000000182,0.0000022555,0.0000003092,-0.0000000546,-0.0000002365,0.0000009095,0.0000003092,-0.0000004184,0.0000006730,-0.0000001091,0.0000001273,0.0000003092,-0.0000005093]','AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(10,10))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),0)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1;-1]),-Inf)
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior(testCase.params),-2.302585092993945e+02,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1;-1]),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,1.0e+09 * [4.170220047031570; 7.203244934424378; 0.001143748183448; 3.023325726325375; 1.467558908179663; 0.923385947697055; 1.862602113784847; 3.455607270437022; 3.967674742312732; 5.388167340038181],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end