classdef AdaptiveSampler < Sampler
    %From Atchadé 2005
    properties(Constant)
        eps_1 = 10^-7
        eps_2 = 10^-6
        A_1 = 10^7;
        StartAdaption = 20;
    end
    
    methods(Static)
        function step = p1(value)
            if value < AdaptiveSampler.eps_1
               step = AdaptiveSampler.eps_1;
            elseif value > AdaptiveSampler.A_1
                step=AdaptiveSampler.A_1;
            else
               step = value;
            end 
        end
        
        function cov_matrix = p2(matrix)
            %scaled by Frobenius norm
            fb = sqrt(trace(matrix*matrix'));
            if fb>AdaptiveSampler.A_1
                cov_matrix=(AdaptiveSampler.A_1/fb)*matrix;
            else
               cov_matrix=matrix;
            end
        end
        
        function means = p3(vector)
            mag = norm(vector);
            if mag  <= AdaptiveSampler.A_1;
                means=vector;
            else
                means = (AdaptiveSampler.A_1/mag)*vector;
            end
        end
        
        function [samples,sampleTime] = blockSample(samplerParams,model,data,proposal,startParams)

            %INPUTS
            %samplerParams - a stucture of sampling parameters
            %model - contains the model specification and likelihood
            %data - the data required to evaluate the model likelihood
            %proposal - Proposal object contains function to use as a proposal
            %startParams - Start Parameters for the sampling

            %OUTPUTS
            %samples - a structure containing the samples, acceptances etc.
            %sampleTime - scalar, time taken in seconds
            
            
            %check that we have a mala or rwmh proposal object       
            if ~(isa(proposal,'RwmhProposal') || ~isa(proposal,'MalaProposal') || ~isa(proposal,'TruncatedMalaProposal'))
                 proposalName = class(proposal);
                 error(strcat ('Proposal ' ,proposalName , ' is not supported for adaptive sampling\n'))
            end
            
            %Samples parameters in a single block
            numOfParamsToSample=model.k;
            samplesToDraw = samplerParams.Samples;
            burninSteps = samplerParams.Burnin;
            userNotify = samplerParams.NotifyEveryXSamples;
            initialStep = samplerParams.AtchadeInitialStep;
            
            %datastructures for sampling   
            paramSamples=zeros(numOfParamsToSample,samplesToDraw);
            proposals=zeros(numOfParamsToSample,samplesToDraw);            
            acceptances = zeros(samplesToDraw,1);
            posteriors=zeros(samplesToDraw,1);
            epsilons=zeros(samplesToDraw,1);
            matrices = zeros(numOfParamsToSample,numOfParamsToSample,samplesToDraw);
            mean_mat=zeros(numOfParamsToSample,samplesToDraw);
            
            %set up the adaption
            covarianceMatrix = AdaptiveSampler.p2(proposal.mass_matrix);
            means = AdaptiveSampler.p3(startParams);
            epsil = AdaptiveSampler.p1(initialStep);
            
            %calculate the current information
            currentInfo = model.calcGradInformation(startParams,data,proposal.RequiredInfo);
            
            t=tic;
            %sampling loop 
            for sampleNo=1:samplesToDraw
                
                if AdaptiveSampler.StartAdaption < sampleNo
                    %start using the adapted matrix to draw posterior
                    %samples
                    if isa(proposal,'MalaProposal') || isa(proposal,'TruncatedMalaProposal')
                        %scaling takes place automatically
                        proposal.mass_matrix = covarianceMatrix+(AdaptiveSampler.eps_2*eye(model.k,model.k));
                        proposal.epsilon = epsil;
                    else
                        %rwmh needs to have the matrix scaled
                        proposal.mass_matrix = epsil*(covarianceMatrix+(AdaptiveSampler.eps_2*eye(model.k,model.k)));
                    end
                end
                
                [alpha,propParams,propInfo] = proposal.propose(model,data,startParams,currentInfo);
                proposals(:,sampleNo) = propParams;

                if alpha == 0 || alpha > log(rand)                      
                    acceptances(sampleNo)=1;
                    posteriors(sampleNo)=propInfo.LogPosterior;
                    currentInfo=propInfo;
                    paramSamples(:,sampleNo)=propParams;
                    startParams=propParams;
                else                        
                    paramSamples(:,sampleNo)=startParams;                       
                    posteriors(sampleNo,:)=currentInfo.LogPosterior;                    
                end
                
                gamma=samplerParams.gamma/sampleNo; %diminish the adaption
                means = AdaptiveSampler.p3(means + (gamma*(paramSamples(:,sampleNo) - means)));
                
                if burninSteps < sampleNo
                    %start estimating the covariance matrix using the
                    %collected means
                    %covarianceMatrix=AdaptiveSampler.p2(covarianceMatrix + (1/sampleNo+1) * ((paramSamples(:,sampleNo)-means)*(paramSamples(:,sampleNo)-means)' - covarianceMatrix));
                    
                    covarianceMatrix=cov(paramSamples(:,1:sampleNo)');
                    if mod(sampleNo,userNotify)==0
                        disp(covarianceMatrix)
                    end
                end
                epsil = AdaptiveSampler.p1(epsil + (gamma*(exp(alpha) - samplerParams.Tau)));              
                epsilons(sampleNo) = epsil;
                matrices(:,:,sampleNo) = covarianceMatrix;
                mean_mat(:,sampleNo)=means;
                
                %notification output
                if mod(sampleNo, userNotify) == 0
                    %update printing
                    fprintf('%d steps performed. Last acceptance=%d, Log-lik = %d, length %d',sampleNo,sum(acceptances(sampleNo-userNotify+1:sampleNo))/userNotify,posteriors(sampleNo),epsil)
                    disp(paramSamples(:,sampleNo)')
                end                       
                
            end
            
            %return samples. Transpose paramSamples and proposals to male
            %tham easier to read
            sampleTime=toc(t); 
            samples=struct('means',mean_mat','covariance',matrices,'epsil', epsilons', 'params',paramSamples','N', samplesToDraw,'acceptances',acceptances,'posteriors',posteriors,'proposals',proposals','sampleTime',sampleTime,'mass_matrix',proposal.mass_matrix,'epsilons',epsilons);
                       
        end

        
    end
    
    
end