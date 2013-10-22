classdef TestBursts < matlab.unittest.TestCase
    properties
        experiment
        experiment2
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
            
            %second test case with a different input file
            datafiles2={[getenv('P_HOME') '/Samples/Simulations/20000/test_2.scn']};
            testCase.experiment2 = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,calc_hessian,datafiles2,modelfile);
        end
    end
    
    methods(Test)
        function testBurst1(testCase)
            testCase.verifyEqual(testCase.experiment.description.data.dataset(1).interval_no,20001);
            testCase.verifyEqual(testCase.experiment.description.data.dataset(1).burst_no,4142);
            testCase.verifyEqual(testCase.experiment.description.data.dataset(1).average_openings_per_burst,1.179623370,'AbsTol',sqrt(eps));
        end
        
        function testBurst2(testCase)
            testCase.verifyEqual(testCase.experiment2.description.data.dataset(1).interval_no,20001);
            testCase.verifyEqual(testCase.experiment2.description.data.dataset(1).burst_no,4060);
            testCase.verifyEqual(testCase.experiment2.description.data.dataset(1).average_openings_per_burst,1.194088670,'AbsTol',sqrt(eps));
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
            clear testCase.experiment2
        end
    end    
    
end

