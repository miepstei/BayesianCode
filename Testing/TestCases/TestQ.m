classdef TestQ < matlab.unittest.TestCase
    %TESTQ Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        experiment
        experiment_desens
    end
    
    methods (TestMethodSetup)
        function createExperiment(testCase)
            concs=[3e-08];
            tres=[2.5e-05];
            tcrits=[0.0035];
            use_chs =[1];
            debug_on=0;
            fit_logspace=1;
            calc_hessian=0;
            datafiles={[getenv('P_HOME') '/Samples/Simulations/20000/test_1.scn']};
            modelfile=[getenv('P_HOME') '/Tools/Mechanisms/model_params_CS 1985_4.mat'];
            testCase.experiment = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles,modelfile);
            
            modelfile2 = [getenv('P_HOME') '/Tools/Mechanisms/model_params_CS 1985_2_desens.mat'];
            testCase.experiment_desens = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles,modelfile2);
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
        
        function testQdesens(testCase)
            Q = testCase.experiment_desens.model.setupQ(testCase.experiment.parameters.concs(1));
            testCase.verifyEqual(Q(1,1),-8000.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,4),2000.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(1,8),6000.0000000000000000,'AbsTol',1e-15);
            
            testCase.verifyEqual(Q(2,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,2),-50000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,5),50000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(2,8),0,'AbsTol',1e-15);
            
            testCase.verifyEqual(Q(3,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,3),-5,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,6),5,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(3,8),0,'AbsTol',1e-15);
            
            testCase.verifyEqual(Q(4,1),52000.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,2),0.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,3),0.000000000000000e+00,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,4),-63500.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,5),10000.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,6),1500.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(4,8),0,'AbsTol',1e-15);
                       
            testCase.verifyEqual(Q(5,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,2),150.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,3),0.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,4),12.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,5),-1662.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,7),1500.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(5,8),0,'AbsTol',1e-15);
            
            testCase.verifyEqual(Q(6,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,3),1.3999999999999999,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,4),5.9999999999999991,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,6),-10007.3999999999996362,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,7),10000.0000000000000000,'AbsTol',1e-15);
            testCase.verifyEqual(Q(6,8),0,'AbsTol',1e-15);            
            
            testCase.verifyEqual(Q(7,1),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,5),5.9999999999999991,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,6),12,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,7),-18,'AbsTol',1e-15);
            testCase.verifyEqual(Q(7,8),0,'AbsTol',1e-15);
            
            testCase.verifyEqual(Q(8,1),50,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,2),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,3),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,4),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,5),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,6),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,7),0,'AbsTol',1e-15);
            testCase.verifyEqual(Q(8,8),-50,'AbsTol',1e-15);            
            
        end
    end
    
end

