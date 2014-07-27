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
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),3.858668411122054e+04,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000,50000,13000,50,15000,10,150000000,6000,5000,150000000],testCase.data),3.355036228698904e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1500,50000,18000,50,15700,17,2e8,4000,5000,100000000],testCase.data),3.852808259951792e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([150,5000,130000,500,1500,10,2e8,8000,7000,50000000],testCase.data),3.349705432531993e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),3.835642560192115e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[0.0502092771057510,-0.0031222640245690,0.7965894164954080,-21.7545295497984625,-0.0100071854831190,1.2337725001998481,-0.0000036950950740,0.3328896062157580,-0.0429271316534140,0.0000048694346330 ]','AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[0.0502092771057510,-0.0031222640245690,0.7965894164954080,-21.7545295497984625,-0.0100071854831190,1.2337725001998481,-0.0000036950950740,0.3328896062157580,-0.0429271316534140,0.0000048694346330 ]','AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:),[0.0004554749466479,-0.0000098589225672,0.0000381442077924,0.0030008050089236,0.0000000727595761,0.0000181898940355,-0.0000002182787284,0.0000107138475869,0.0000086220097728,0.0000000181898940,-0.0000098589225672,-0.0000007275957614,-0.0000013642420527,-0.0001383159542456,-0.0000005275069270,-0.0000016552803572,0.0000000363797881,-0.0000002910383046,-0.0000003456079867,-0.0000002728484105,0.0000381442077924,-0.0000013642420527,0.0005613401299343,-0.0055805139709264,-0.0000044565240387,0.0004684079613071,-0.0000005638867151,0.0001357511791866,-0.0000064392224886,0.0000000545696821,0.0030008050089236,-0.0001383159542456,-0.0055805139709264,-0.4868248652201146,-0.0000791078491602,-0.0020677907741629,0.0000005275069270,-0.0035238190321252,0.0003021523298230,-0.0000000545696821,0.0000000727595761,-0.0000005275069270,-0.0000044565240387,-0.0000791078491602,0.0000018917489797,0.0000038016878534,-0.0000004001776688,0.0000007457856555,0.0000001818989404,0.0000002182787284,0.0000181898940355,-0.0000016552803572,0.0004684079613071,-0.0020677907741629,0.0000038016878534,0.0044926855480298,0.0000003274180926,0.0001301850716118,-0.0000034197000787,-0.0000001455191523,-0.0000002182787284,0.0000000363797881,-0.0000005638867151,0.0000005275069270,-0.0000004001776688,0.0000003274180926,0.0000005093170330,0.0000000363797881,0.0000000181898940,0.0000006730260793,0.0000107138475869,-0.0000002910383046,0.0001357511791866,-0.0035238190321252,0.0000007457856555,0.0001301850716118,0.0000000363797881,0.0004994217306376,-0.0000006366462912,0.0000008549250197,0.0000086220097728,-0.0000003456079867,-0.0000064392224886,0.0003021523298230,0.0000001818989404,-0.0000034197000787,0.0000000181898940,-0.0000006366462912,0.0000016734702513,0.0000005275069270,0.0000000181898940,-0.0000002728484105,0.0000000545696821,-0.0000000545696821,0.0000002182787284,-0.0000001455191523,0.0000006730260793,0.0000008549250197,0.0000005275069270,-0.0000006548361853]','AbsTol', 1e-6)
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