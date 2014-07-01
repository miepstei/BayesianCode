classdef TestMmalaProposal <matlab.unittest.TestCase
    properties
        proposal
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.proposal = SimpMmalaProposal(0.04);
            testCase.model=NormalModel();
            testCase.params=[0; 10];
            a=load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/NormData.mat'));
            testCase.data = a.data;
        end
    end    
    
    methods(Test)
        function testProperties(testCase)

            %check epsilon
            testCase.verifyEqual(testCase.proposal.epsilon,0.04)
            
            testCase.proposal.epsilon = 0.05;
            testCase.verifyEqual(testCase.proposal.epsilon,0.05)
            
            try
                testCase.proposal.epsilon = 0;
            catch ME
                testCase.verifyEqual(ME.identifier,'MmalaProposal:epsilon:Negative','epsilon must be positive');
            end
            
            try
                testCase.proposal.epsilon = -0.05;
            catch ME
                testCase.verifyEqual(ME.identifier,'MmalaProposal:epsilon:Negative','epsilon must be positive');
            end
            
            
        end
        
        function testPropose(testCase)
            rng(1)
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,SimpMmalaProposal.RequiredInfo);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),-1.1101343989673376e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(currInfo.LogPosterior,-1.1184284486074396e+03,'AbsTol', 1e-12);
            
            
            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-0.003463336721552,'AbsTol', 1e-12);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.1102221928817621e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propInfo.LogPosterior,-1.1185162425218641e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propParams,[-0.080178278106716; 10.092226677549094],'AbsTol', 1e-12);
            rng('shuffle', 'twister')
        end
        
    end
    
end