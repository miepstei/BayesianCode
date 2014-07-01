classdef TestRwmhProposal < matlab.unittest.TestCase
    properties
        proposal
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.proposal = RwmhProposal(eye(2,2),0);
            testCase.model=NormalModel();
            testCase.params=[0; 10];
            a=load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/NormData.mat'));
            testCase.data = a.data;
        end
    end
    
    methods(Test)
        function testProperties(testCase)
            
            %check defaults
            testCase.verifyEqual(testCase.proposal.mass_matrix,eye(2,2));
            
            %check non-positive definiteness
            try
                testCase.proposal.mass_matrix = -eye(2,2);
            catch ME
                testCase.verifyEqual(ME.identifier,'RwmhProposal:mass_matrix:notPosDef');
            end
            
            %check componentwise
            testCase.proposal.componentwise=1;
            testCase.verifyEqual(testCase.proposal.componentwise,1);
            
            testCase.proposal.componentwise=0;
            testCase.verifyEqual(testCase.proposal.componentwise,0);
            try
                testCase.proposal.componentwise=2;
            catch ME
                testCase.verifyEqual(ME.identifier,'RwmhProposal:componentwise:invalidComponent');                
            end

        end
        
        %tests bivariate proposal
        function testPropose(testCase)
            rng(1);
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,RwmhProposal.RequiredInfo);
            testCase.verifyEqual(currInfo.LogPosterior,testCase.model.calcLogLikelihood(testCase.params,testCase.data)+testCase.model.calcLogPrior(testCase.params),'AbsTol', 1e-10);

            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-4.8388639894058088,'AbsTol', 1e-10);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.1149732629567434e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propInfo.LogPosterior,-1.1232673125968454e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propParams,[-6.4901376519124065e-01; 1.1181166041965533e+01],'AbsTol', 1e-10);
            rng('shuffle', 'twister')
        end
        
        %tests componentwise proposal
        function testProposeCw(testCase)
            
            %fix random number generator
            rng(1);
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,RwmhProposal.RequiredInfo);
            testCase.verifyEqual(currInfo.LogPosterior,testCase.model.calcLogLikelihood(testCase.params,testCase.data)+testCase.model.calcLogPrior(testCase.params),'AbsTol', 1e-10);
            
            %first param
            [alpha,propParams,propInfo] = testCase.proposal.proposeCw(testCase.model,testCase.data,testCase.params,1,currInfo);
            testCase.verifyEqual(alpha,-0.122032171591400,'AbsTol', 1e-10);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110256431138929e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propInfo.LogPosterior,-1.1185504807790310e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propParams,[-0.649013765191241; 10],'AbsTol', 1e-10);
            
            %second param
            [alpha,propParams,propInfo] = testCase.proposal.proposeCw(testCase.model,testCase.data,testCase.params,2,currInfo);
            testCase.verifyEqual(alpha,-4.741252678349838,'AbsTol', 1e-10);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.114875651645687e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propInfo.LogPosterior,-1.1231697012857894e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propParams,[0; 11.181166041965533],'AbsTol', 1e-10);
            
            rng('shuffle', 'twister')
        end

    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end
