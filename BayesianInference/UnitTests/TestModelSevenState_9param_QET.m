classdef TestModelSevenState_9param_QET < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            testCase.model = SevenState_9param_AT();
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
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),3.9053949436e+04,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood([15000,50000,13000,50,15000,10,6000,5000,150000000],testCase.data),3.3484627213e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1500,50000,18000,50,15700,17,4000,5000,100000000],testCase.data),3.848835872187513e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([150,5000,130000,500,1500,10,8000,7000,50000000],testCase.data),3.4620300521e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),3.884671677782716e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            mt = testCase.model.calcMetricTensor(testCase.params,testCase.data);
            testCase.verifyEqual(mt(:),[0.0006146001396701,-0.0000126601662487,-0.0000188629201148,0.0013718818081543,-0.0000018917489797,0.0008288043318316,0.0000031286617741,0.0000155887391884,0.0000007457856555,-0.0000126601662487,0.0000005820766091,0.0000013278622646,-0.0000524414645042,-0.0000001273292582,-0.0000434920366388,-0.0000013460521586,-0.0000008185452316,0.0000005638867151,-0.0000188629201148,0.0000013278622646,0.0000034197000787,0.0006456684786826,0.0000051295501180,-0.0004548201104626,-0.0000066393113229,0.0000025829649530,-0.0000001273292582,0.0013718818081543,-0.0000524414645042,0.0006456684786826,0.0108738458948210,-0.0001840453478508,-0.0461948729935102,-0.0001794978743419,0.0006818299880251,0.0000009276845958,-0.0000018917489797,-0.0000001273292582,0.0000051295501180,-0.0001840453478508,-0.0000003637978807,0.0011433985491749,0.0000010186340660,-0.0000020190782379,0.0000005093170330,0.0008288043318316,-0.0000434920366388,-0.0004548201104626,-0.0461948729935102,0.0011433985491749,-0.1278575655305758,0.0005890797183383,-0.0003985223884229,-0.0000005820766091,0.0000031286617741,-0.0000013460521586,-0.0000066393113229,-0.0001794978743419,0.0000010186340660,0.0005890797183383,0.0000068394001573,0.0000092768459581,-0.0000002910383046,0.0000155887391884,-0.0000008185452316,0.0000025829649530,0.0006818299880251,-0.0000020190782379,-0.0003985223884229,0.0000092768459581,0.0000035652192309,0.0000004729372449,0.0000007457856555,0.0000005638867151,-0.0000001273292582,0.0000009276845958,0.0000005093170330,-0.0000005820766091,-0.0000002910383046,0.0000004729372449,0.0000021100277081]','AbsTol', 1e-6)
        end
        
        function testCalcDerivMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcDerivMetricTensor(testCase.params,testCase.data),zeros(9,9))
        end
        
        function testCalcDerivLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior(testCase.params),0)
            testCase.verifyEqual(testCase.model.calcDerivLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1]),-Inf)
        end
        
        function testCalcLogPrior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPrior(testCase.params),-2.072326583694551e+02,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogPrior([-1; -1;-1; -1; -1; -1 ;-1; -1; -1]),-Inf)
        end
        
        function testSamplePrior(testCase)
            rng(1)
            testCase.verifyEqual(testCase.model.samplePrior,1.0e+09 * [ 4.170220047031570 ;  7.203244934424378 ;  0.001143748183448 ;  3.023325726325375 ;  1.467558908179663  ; 0.923385947697055 ;  1.862602113784847 ;  3.455607270437022;   3.967674742312732],'AbsTol', 1e-6)
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end