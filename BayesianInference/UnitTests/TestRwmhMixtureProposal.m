classdef TestRwmhMixtureProposal < matlab.unittest.TestCase
    properties
        proposal
        model
        params
        data
    end
    
    methods (TestClassSetup)
        function createExperiment(testCase)
            testCase.proposal = RwmhMixtureProposal(eye(2,2),0);
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
            testCase.proposal.componentwise=0;
            testCase.verifyEqual(testCase.proposal.componentwise,0);
            try
                testCase.proposal.componentwise=1;
            catch ME
                testCase.verifyEqual(ME.identifier,'RwmhProposal:componentwise:invalidComponent');                
            end
            
            %check beta
            testCase.proposal.beta=0;
            testCase.verifyEqual(testCase.proposal.beta,0);
            
            try
                testCase.proposal.beta=1.1;
            catch ME
                testCase.verifyEqual(ME.identifier,'RwmhProposal:beta:invalid');                
            end      
            
            try
                testCase.proposal.beta=-1.1;
            catch ME
                testCase.verifyEqual(ME.identifier,'RwmhProposal:beta:invalid');                
            end
            
            %reset beta
            testCase.proposal.beta=0.05;
            testCase.verifyEqual(testCase.proposal.beta,0.05);            
        end
        
        %test joint proposal
        function testProposeBegin(testCase)
            rng(1);
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,RwmhMixtureProposal.RequiredInfo);
            testCase.verifyEqual(currInfo.LogPosterior,testCase.model.calcLogLikelihood(testCase.params,testCase.data)+testCase.model.calcLogPrior(testCase.params),'AbsTol', 1e-10);

            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-0.092599864959084,'AbsTol', 1e-10);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.110226998832297e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propInfo.LogPosterior,-1.118521048472399e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propParams,[-0.045892203445014; 10.083521051798110],'AbsTol', 1e-10);
            rng('shuffle', 'twister')
        end
        function testProposeMixture(testCase)
            rng(1);
            testCase.proposal.mixture=1;
            currInfo = testCase.model.calcGradInformation(testCase.params,testCase.data,RwmhMixtureProposal.RequiredInfo);
            testCase.verifyEqual(currInfo.LogPosterior,testCase.model.calcLogLikelihood(testCase.params,testCase.data)+testCase.model.calcLogPrior(testCase.params),'AbsTol', 1e-10);

            [alpha,propParams,propInfo] = testCase.proposal.propose(testCase.model,testCase.data,testCase.params,currInfo);
            testCase.verifyEqual(alpha,-10.413053837040707,'AbsTol', 1e-10);
            testCase.verifyEqual(testCase.model.calcLogLikelihood(propParams,testCase.data),-1.120547452804378e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propInfo.LogPosterior,-1.128841502444480e+03,'AbsTol', 1e-10);
            testCase.verifyEqual(propParams,[-1.040304257240379; 11.884487906635183],'AbsTol', 1e-10);
            rng('shuffle', 'twister')
        end
    end
    
    methods (TestMethodTeardown)
        function destroyExperiment(testCase)
            clear testCase.experiment
        end
    end    
    
end