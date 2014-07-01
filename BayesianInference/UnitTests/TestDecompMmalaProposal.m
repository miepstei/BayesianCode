classdef TestDecompMmalaProposal <matlab.unittest.TestCase
    properties
        proposal
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.proposal = SimpMmalaProposalDecomp(0.04);
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
            testCase.verifyEqual(alpha,-0.015612287214026,'AbsTol', 1e-12);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110400556039194e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118694605679296e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propParams,[-0.136678743489180; 10.191747913090740],'AbsTol', 1e-12);
            rng('shuffle', 'twister')
        end
        
        function testProposeNotPosDef(testCase)
            rng(1)
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,SimpMmalaProposal.RequiredInfo);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(testCase.params,testCase.data),-1.1101343989673376e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(currInfo.LogPosterior,-1.1184284486074396e+03,'AbsTol', 1e-12);
            
            %corrupt the MT to make the covariance proposal not positive
            %definate
            currInfo.MetricTensor = [-3 0; 0 -6];
            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-0.015612287214026,'AbsTol', 1e-12);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110400556039194e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118694605679296e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propParams,[-0.136678743489180; 10.191747913090740],'AbsTol', 1e-12);
            
            %corrupt the MT to make the covariance proposal not positive
            %definate            
            rng(1)
            currInfo.MetricTensor = [-1.5 0; 0 -8];
            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,0,'AbsTol', 1e-12);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110386918049145e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118680967689247e+03,'AbsTol', 1e-12);
            testCase.verifyEqual(propParams,[-0.140896212030146; 10.186454952569900],'AbsTol', 1e-12);            
            
            rng('shuffle', 'twister')            
            
        end
        
    end
    
    
end