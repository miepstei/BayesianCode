classdef TestModelEightState_12Param_AT < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            
            testCase.model = EightState_12Param_AT();
            testCase.params=[2000.0000 52000.0000 6000.0000 50.0000 50000.0000 150.0000 200000000.0000 1500.0000 10000.0000 400000000.0000 5.0000 1.4000 ]'; %true1 rate constants
            testCase.data.concs = 1;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.model.kA,3);
            testCase.verifyEqual(testCase.model.h,0.01);
            testCase.verifyEqual(testCase.model.k,12);
            
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
            %from profile likelihood experiments generated data
            testCaseQ=[-2005.00000000 0.00000000 0.00000000 52000.00000000 0.00000000 0.00000000 0.00000000 1.40000000 0.00000000 -6000.00000000 0.00000000 0.00000000 50.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 -50000.00000000 0.00000000 0.00000000 150.00000000 0.00000000 0.00000000 2000.00000000 0.00000000 0.00000000 -63500.00000000 400000000.00000000 200000000.00000000 0.00000000 0.00000000 0.00000000 6000.00000000 0.00000000 10000.00000000 -400001550.00000000 0.00000000 200000000.00000000 0.00000000 0.00000000 0.00000000 50000.00000000 1500.00000000 0.00000000 -200010150.00000000 399999999.99999934 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 1500.00000000 10000.00000000 -599999999.99999928 0.00000000 5.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 -1.40000000 ]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-6);
            
            Q=testCase.model.generateQ(testCase.params,0.01);
            testCaseQ=[-2005.00000000 0.00000000 0.00000000 52000.00000000 0.00000000 0.00000000 0.00000000 1.40000000 0.00000000 -6000.00000000 0.00000000 0.00000000 50.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 -50000.00000000 0.00000000 0.00000000 150.00000000 0.00000000 0.00000000 2000.00000000 0.00000000 0.00000000 -63500.00000000 4000000.00000000 2000000.00000000 0.00000000 0.00000000 0.00000000 6000.00000000 0.00000000 10000.00000000 -4001550.00000000 0.00000000 2000000.00000000 0.00000000 0.00000000 0.00000000 50000.00000000 1500.00000000 0.00000000 -2010150.00000000 3999999.99999999 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 1500.00000000 10000.00000000 -5999999.99999999 0.00000000 5.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 0.00000000 -1.40000000]';
            testCase.verifyEqual(Q(:),testCaseQ,'AbsTol', 1e-6);

        end
        
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end