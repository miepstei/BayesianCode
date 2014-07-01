classdef TestTruncatedMalaProposal <matlab.unittest.TestCase
    properties
        proposal
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.proposal = TruncatedMalaProposal(eye(2,2),0.04,10000);
            testCase.model=NormalModel();
            testCase.params=[0; 10];
            a=load(strcat(getenv('P_HOME'), '/BayesianInference/UnitTests/TestData/NormData.mat'));
            testCase.data = a.data;
        end
    end    
    
    methods(Test)    
        function testProperties(testCase)
            
            %check non-positive definiteness for mass M
            testCase.verifyEqual(testCase.proposal.mass_matrix,eye(2,2))

            try
                testCase.proposal.mass_matrix = -eye(2,2);
            catch ME
                testCase.verifyEqual(ME.identifier,'MalaProposal:mass_matrix:notPosDef');
            end            
            
            %check epsilon
            testCase.verifyEqual(testCase.proposal.epsilon,0.04)
            
            testCase.proposal.epsilon = 0.05;
            testCase.verifyEqual(testCase.proposal.epsilon,0.05)
            
            try
                testCase.proposal.epsilon = 0;
            catch ME
                testCase.verifyEqual(ME.identifier,'MalaProposal:epsilon:Negative','epsilon must be positive');
            end
            
            try
                testCase.proposal.epsilon = -0.05;
            catch ME
                testCase.verifyEqual(ME.identifier,'MalaProposal:epsilon:Negative','epsilon must be positive');
            end    

            testCase.proposal.truncation = 0.05;
            testCase.verifyEqual(testCase.proposal.truncation,0.05)            
            
            try
                testCase.proposal.truncation = -0.05;
            catch ME
                testCase.verifyEqual(ME.identifier,'MalaProposal:truncation:Negative','truncaton factor must be positive');
            end
            testCase.proposal.truncation = 10000;
            testCase.verifyEqual(testCase.proposal.truncation,10000)               
        end
        
        function testPropose(testCase)
            %Want this to be the same as mala
            rng(1)
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,MalaProposal.RequiredInfo);
            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-2.1198171588821424e-02,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.1104426987019910e+03,'AbsTol', 1e-6);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118736748342093e+03,'AbsTol', 1e-6);
            testCase.verifyEqual(propParams,[-1.4551262413383481e-01; 1.0210942452823998e+01],'AbsTol', 1e-6);
            rng('shuffle', 'twister')
        end
        
        function testTruncatedPropose(testCase)
            %Should induce strong truncation of the drift
            testCase.proposal.truncation = 0.0000001;
            rng(1)
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,MalaProposal.RequiredInfo);
            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-0.376307861202122,'AbsTol', 1e-6);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110510706845872e+03,'AbsTol', 1e-6);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118804756485974e+03,'AbsTol', 1e-6);
            testCase.verifyEqual(propParams,[-0.129802754093564; 10.236233206694191],'AbsTol', 1e-6);            
            rng('shuffle', 'twister')
        end
        
        
    end
end