classdef TestQ < matlab.unittest.TestCase
    %TESTQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        experiment
    end
    
    methods (TestMethodSetup)
        function createExperiment(testCase)
            concs=[3e-08];
            tres=[2.5e-05];
            tcrits=[0.0035];
            use_chs =[1];
            debug_on=0;
            fit_logspace=1;
            datafiles={[getenv('P_HOME') '/Samples/Simulations/20000/test_1.scn']};
            modelfile=[getenv('P_HOME') '/Tools/Mechanisms/model_params_CS 1985_4.mat'];
            testCase.experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,datafiles,modelfile);
        end
    end
    
    methods (Test)
        function testQ(testCase)
            Q = testCase.experiment.model.setupQ(testCase.experiment.parameters.concs(1));
            testCase.verifyEqual(Q(1,1),-1.500000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,4),1.500000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,2),-1.300000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,5),1.300000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,3),-1.500000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,6),1.500000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,1),5.000000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,2),0.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,3),0.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,4),-6.100000000000000e+04,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,5),5.000000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,6),6.000000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,2),5.000000000000000e+01,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,4),3.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,5),-6.053000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,7),6.000000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,3),1.000000000000000e+01,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,4),3.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,5),0.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,6),-5.013000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,7),5.000000000000000e+03,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,5),3.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,6),3.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,7),-5.999999999999999e+00,'AbsTol',1e-15);
        end
    end
    
end

