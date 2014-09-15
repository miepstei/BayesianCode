classdef TestModelPredictions < matlab.unittest.TestCase
    properties
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.model=SevenState_10Param_AT();
            testCase.params=[0; 10];
            testCase.data=load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/pdftest.mat'));
            testCase.data.t=testCase.data.t/1000; %convert to s
            testCase.data.tc=testCase.data.tc/1000; %convert to s
            testCase.data.tres=2e-5;
            testCase.data.conc=50e-9;
            %data calculated witha  tres =2e-5 and a conc = 50e-9
        end
    end    
    
    methods(Test)    

        
        function testIdealOpenPdf(testCase)
            %Want this to be the same as dc-pyps generated datafile
            [open_t, open_p, ~, ~] = open_ideal_pdf(testCase.data.Q,3,4,2e-5,1);
            testCase.verifyEqual(open_t,testCase.data.t,'AbsTol', 1e-10);
            testCase.verifyEqual(open_p,testCase.data.ideal,'AbsTol', 1e-10);
        end
        
        function testIdealClosePdf(testCase)
            %Want this to be the same as dc-pyps generated datafile
            [close_t, close_p, ~, ~] = close_ideal_pdf(testCase.data.Q,3,4,2e-5,1);
            testCase.verifyEqual(close_t,testCase.data.tc,'AbsTol', 1e-10);
            testCase.verifyEqual(close_p,testCase.data.ideal_c,'AbsTol', 1e-10);
        end
        
        function testAsymptoticOpenPdf(testCase)
            [open_t, open_p, open_areas ,open_roots] = open_asymptotic_pdf(testCase.data.Q,3,4,2e-5,1,testCase.data.t);
            testCase.verifyEqual(open_t,testCase.data.t,'AbsTol', 1e-10);
            testCase.verifyEqual(open_p,testCase.data.asymptotic,'AbsTol', 1e-7);
            testCase.verifyEqual(open_areas,testCase.data.open_asymptotic_areas,'AbsTol', 1e-7);  
        end
        
        function testAsymptoticClosePdf(testCase)
            [close_t, close_p, close_areas, close_roots] = close_asymptotic_pdf(testCase.data.Q,3,4,2e-5,1);
            testCase.verifyEqual(close_t,testCase.data.tc,'AbsTol', 1e-10);
            testCase.verifyEqual(close_p,testCase.data.asymptotic_c,'AbsTol', 1e-10);
            testCase.verifyEqual(close_areas,testCase.data.close_asymptotic_areas,'AbsTol', 1e-10);  
        end
        
        function testOpenRoots(testCase)
            kx=3;
            ky=4;
            
            Qxx = testCase.data.Q(1:kx,1:kx);
            Qyy = testCase.data.Q(ky:end,ky:end);
            Qxy = testCase.data.Q(1:kx,ky:end);
            Qyx = testCase.data.Q(ky:end,1:kx);
            
            [open_roots, ~] = asymptotic_roots( testCase.data.tres, Qxx, Qyy, Qxy, Qyx, kx, ky,0 );
            
            testCase.verifyEqual(open_roots,testCase.data.open_asymptotic_roots,'AbsTol', 1e-10);  
        end
        
        function testOpenARfunction(testCase)
            kx=3;
            ky=4;
            
            Qxx = testCase.data.Q(1:kx,1:kx);
            Qyy = testCase.data.Q(ky:end,ky:end);
            Qxy = testCase.data.Q(1:kx,ky:end);
            Qyx = testCase.data.Q(ky:end,1:kx);            
            
            
            R=AR(testCase.data.open_asymptotic_roots,testCase.data.tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
            testCase.verifyEqual(R,permute(testCase.data.aAR,[3 2 1]),'AbsTol', 1e-4);
        end
     
    end
end