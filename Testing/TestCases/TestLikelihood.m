classdef TestLikelihood < matlab.unittest.TestCase
    properties
        experiment
        experiment_limit
        lik
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
            testCase.experiment_limit = setup_experiment(tres,tcrits,concs,use_chs,debug_on,fit_logspace,datafiles,modelfile);
            testCase.lik=DCProgsExactLikelihood;
        end
    end
    
    methods(Test)
        function testLikelihood(testCase)
            likelihood = testCase.lik.calculate_likelihood(testCase.experiment);
            testCase.verifyEqual(likelihood,-39053.9494363204,'AbsTol',sqrt(eps));
            %easy tolerance of comparison with dc-pyps
            testCase.verifyEqual(likelihood,-39053.9222259734960971,'AbsTol',1e-1);
        end
        
        function testEvaluateLikelihood(testCase)
            %test mimics what happens when simplex calculates ->
            %(parameters,experiment)
            [likelihood,params] = testCase.lik.evaluate_function(testCase.experiment.model.getParameters(true),testCase.experiment);
            testCase.verifyEqual(likelihood,-39053.9494363204,'AbsTol',sqrt(eps));
            testCase.verifyEqual(likelihood,-39053.9222259734960971,'AbsTol',1e-1);
            
            %now we want to test that the params are unchanged as update
            %was within limits
            
            model_params = testCase.experiment.model.getParameters(1);
            keys = model_params.keys;
            for i=1:length(keys)
                 testCase.verifyEqual(params(keys{i}),model_params(keys{i}),'AbsTol',sqrt(eps));      
            end
        end
        
        function testEvaluateLikelihoodLimits(testCase)
            params=testCase.experiment.model.getParameters(true);
            params(14)=log(15000000000);
            [likelihood,evaluated_params] = testCase.lik.evaluate_function(params,testCase.experiment);
            testCase.verifyEqual(likelihood,-39078.74966936554,'AbsTol',sqrt(eps));
            
            %now we test that params(14) has been reset by hitting the
            %upper limit
            
            testCase.verifyEqual(params(1),evaluated_params(1),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(2),evaluated_params(2),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(3),evaluated_params(3),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(4),evaluated_params(4),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(5),evaluated_params(5),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(6),evaluated_params(6),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(11),evaluated_params(11),'AbsTol',sqrt(eps))
            testCase.verifyEqual(params(13),evaluated_params(13),'AbsTol',sqrt(eps))
            testCase.verifyEqual(evaluated_params(14),log(10000000000),'AbsTol',sqrt(eps))
            testCase.verifyNotEqual(evaluated_params(14),log(15000000000))           
        end
        
        function testEvaluateLikelihoodCrash(testCase)
            %These parameter values are sure to crash DCP
            keys = cell2mat(testCase.experiment.model.getParameters(1).keys);
            values = log([6137646.4570370633155107 1339408.5226465812884271 187777.6245156960503664 ...
                        1350623.0997633493971080 935080.4305853805271909 144235.3726986660913099 ...
                        411820.7426744225667790 808682.8009984717937186 10000000000.0000000000000000]);
                    
            crashParams=containers.Map(keys,values);
            
            [likelihood,~,error] = testCase.lik.evaluate_function(crashParams,testCase.experiment);
            testCase.verifyEqual(likelihood,0,'AbsTol',sqrt(eps))
            testCase.verifyEqual(error,1,'AbsTol',sqrt(eps))
            
        end
    end

    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
            clear testCase.experiment_limit
            clear testCase.lik
        end
    end

end

