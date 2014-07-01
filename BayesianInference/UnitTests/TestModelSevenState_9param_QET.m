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
            testCase.verifyEqual(testCase.model.calcLogLikelihood([1500,50000,18000,50,15700,17,4000,5000,100000000],testCase.data),3.8488358723e+04,'AbsTol', 1e-6)
            testCase.verifyEqual(testCase.model.calcLogLikelihood([150,5000,130000,500,1500,10,8000,7000,50000000],testCase.data),3.4620300521e+04,'AbsTol', 1e-6)
        end
        
        function testCalcLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcLogPosterior(testCase.params,testCase.data),3.8846716778e+04,'AbsTol', 1e-6)
        end
        
        function testCalcGradLogLikelihood(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogLikelihood(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcGradLogPosterior(testCase)
            testCase.verifyEqual(testCase.model.calcGradLogPosterior(testCase.params,testCase.data),[2.4902670739e-01; -5.5877226259e-03; -1.0079326130e-01; -4.2312582958e+00; -1.1382801677e-02; -9.5985965854e+00; -4.9758025852e-03; -1.6303263692e-02; 2.8659997042e-06 ],'AbsTol', 1e-6)
        end
        
        function testCalcMetricTensor(testCase)
            testCase.verifyEqual(testCase.model.calcMetricTensor(testCase.params,testCase.data),[0.000609070411883295,-1.26965460367501e-05,-1.94631866179407e-05,0.00137142706080340,-1.74622982740402e-06,0.000828749762149528,3.49245965480804e-06,1.56978785526007e-05,-2.36468622460961e-07;-1.26965460367501e-05,-7.27595761418343e-08,2.91038304567337e-07,-5.25687937624753e-05,-5.45696821063757e-08,-4.32373781222850e-05,-8.00355337560177e-07,-7.27595761418343e-07,5.27506927028298e-07;-1.94631866179407e-05,2.91038304567337e-07,-3.27418092638254e-06,0.000644631654722616,4.82032191939652e-06,-0.000456420821137726,-5.23868948221207e-06,1.60071067512035e-06,-1.63709046319127e-07;0.00137142706080340,-5.25687937624753e-05,0.000644631654722616,0.0108661333797500,-0.000184481905307621,-0.0461944910057355,-0.000179916241904721,0.000681320670992136,-2.54658516496420e-07;-1.74622982740402e-06,-5.45696821063757e-08,4.82032191939652e-06,-0.000184481905307621,-5.16592990607023e-06,0.00114425347419456,1.27329258248210e-06,-2.43744580075145e-06,3.63797880709171e-08;0.000828749762149528,-4.32373781222850e-05,-0.000456420821137726,-0.0461944910057355,0.00114425347419456,-0.127863313537091,0.000587515387451276,-0.000397631083615124,2.00088834390044e-07;3.49245965480804e-06,-8.00355337560177e-07,-5.23868948221207e-06,-0.000179916241904721,1.27329258248210e-06,0.000587515387451276,2.47382558882237e-06,9.51331458054483e-06,-5.45696821063757e-07;1.56978785526007e-05,-7.27595761418343e-07,1.60071067512035e-06,0.000681320670992136,-2.43744580075145e-06,-0.000397631083615124,9.51331458054483e-06,2.91038304567337e-07,4.00177668780088e-07;-2.36468622460961e-07,5.27506927028298e-07,-1.63709046319127e-07,-2.54658516496420e-07,3.63797880709171e-08,2.00088834390044e-07,-5.45696821063757e-07,4.00177668780088e-07,-4.07453626394272e-06],'AbsTol', 1e-6)
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