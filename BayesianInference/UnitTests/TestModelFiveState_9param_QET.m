classdef TestModelFiveState_9param_QET < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            testCase.model = FiveState_9Param_QET();
            testCase.params=[500000000 3000 500 15000 2000 15 500000000 2000 50000000]';
            testCase.data.tres = 0.000025;
            testCase.data.concs = 10^-7;
            testCase.data.tcrit = 0.004;
            [testCase.data.bursts,~] = load_data(strcat(getenv('P_HOME'), {'/Samples/Simulations/two_state_20000.scn'}),testCase.data.tres,testCase.data.tcrit);
            testCase.data.useChs=1;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.model.kA,2);
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
        end
        
        %test Q generation
        function testQ(testCase)
            Q=testCase.model.generateQ(testCase.params,10^-7);
            %from 2003 blue book
            testCaseQ=[-3050,50,0,3000,0;2/3,-(500+(2/3)),500,0,0;0,15000,-19000,4000,0;15,0,50,-2065,2000;0,0,0,10,-10];
            testCase.verifyEqual(Q,testCaseQ,'AbsTol', 1e-10);          
        end
        
        function testLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([500000000 3000 500 15000 2000 15 500000000 2000 50000000],testCase.data),4.483204406943250e+04,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([50000000 3000 500 15000 2000 15 50000000 200 50000000],testCase.data),5.200965439835204e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([500000000 300 500 1500 2000 15 500000000 2000 50000000],testCase.data), 3.948064112963049e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([5000000 3000 500 1500 200 15 50000000 200 50000000],testCase.data),5.201498837215643e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),4.468007345335490e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),1.0e+02 *[-0.000000000500229;0.015204598184709;0.015089218242951;-0.001002220951726;0.007427478272855;2.870148371331124;-0.000000084768156;-0.002160020103486;0.000000018177464],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),1.0e+02 *[-0.000000000500229;0.015204598184709;0.015089218242951;-0.001002220951726;0.007427478272855;2.870148371331124;-0.000000084768156;-0.002160020103486;0.000000018177464],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:)',[ -0.0000000000000000,0.0000000000022867,-0.0000000000207744,0.0000000000004802,-0.0000000000035085,0.0000000004182923,-0.0000000000000000,-0.0000000000000223,0.0000000000000000,0.0000000000022867,0.0006348282614875,0.0003054741237257,-0.0000056820054130,0.0000400662990555,-0.0125118813972140,0.0000000003694651,0.0000010056169096,-0.0000000000039010,-0.0000000000207744,0.0003054741237257,0.0004916101162806,0.0000516188734280,-0.0003715872358440,0.0872489096556879,-0.0000000025924371,-0.0000029661587319,0.0000000000308419,0.0000000000004802,-0.0000056820054130,0.0000516188734280,-0.0000100218696628,0.0000243532454189,-0.0029418201860927,0.0000000000910267,-0.0000007782333528,-0.0000000000013903,-0.0000000000035085,0.0000400662990555,-0.0003715872358440,0.0000243532454189,0.0001884913283618,0.0214092860657622,-0.0000000006734870,0.0000075035929275,-0.0000000000004695,0.0000000004182923,-0.0125118813972140,0.0872489096556879,-0.0029418201860927,0.0214092860657622,22.0118995917145419,-0.0000000806689180,-0.0015115285442917,-0.0000000003046519,-0.0000000000000000,0.0000000003694651,-0.0000000025924371,0.0000000000910267,-0.0000000006734870,-0.0000000806689180,-0.0000000000000140,-0.0000000001395449,0.0000000000000001,-0.0000000000000223,0.0000010056169096,-0.0000029661587319,-0.0000007782333528,0.0000075035929275,-0.0015115285442917,-0.0000000001395449,-0.0000952303532916,-0.0000000014646891,0.0000000000000000,-0.0000000000039010,0.0000000000308419,-0.0000000000013903,-0.0000000000004695,-0.0000000003046519,0.0000000000000001,-0.0000000014646891,0.0000000000000256],'AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(9,9))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),0)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(repmat(-1,1,13)),-Inf)
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior(testCase.params),-1.519706160776040e+02,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior(repmat(-1,1,13)),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,1.0e+09 *[4.170220047031570;0.000720324496239;0.000000114384816;0.000302332579609;0.000146755899350;0.000092338603845;1.862602113784847;0.000345560733587;3.967674742312732],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end