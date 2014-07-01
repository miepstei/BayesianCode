classdef RosenthalAdaptiveSampler < Sampler
    %From Rosenthal 2006 technical report
   
    properties(Constant)
        StartAdaption = 20;
    end
    
    methods(Static)
        
        function samples = blockSample(samplerParams,model,data,proposal,startParams)

            %INPUTS
            %samplerParams - a stucture of sampling parameters
            %model - contains the model specification and likelihood
            %data - the data required to evaluate the model likelihood
            %proposal - Proposal object contains function to use as a proposal,
            %startParams - params from which to start

            %OUTPUTS
            %samples - a structure containing the samples, acceptances etc.
            
            
            %check that we have a mala or rwmh proposal object       
            if ~(isa(proposal,'RwmhMixtureProposal') || isa(proposal,'TruncatedMalaProposal') || isa(proposal,'MalaProposal'))
                 proposalName = class(proposal);
                 error(strcat ('Proposal ' ,proposalName , ' is not supported for Rosenthal adaptive sampling\n'))
            end
            
            %Samples parameters in a single block
            numOfParamsToSample=model.k;
            samplesToDraw = samplerParams.Samples;
            userNotify = samplerParams.NotifyEveryXSamples;
            burnIn = samplerParams.Burnin;
            burninAdjustLag = samplerParams.AdjustmentLag;
            scaleFactor = 1;
            scaleFactors= ones(samplesToDraw,1);
  
            %datastructures for sampling   
            paramSamples=zeros(numOfParamsToSample,samplesToDraw);
            proposals=zeros(numOfParamsToSample,samplesToDraw);            
            acceptances = zeros(samplesToDraw,1);
            posteriors=zeros(samplesToDraw,1);
            matrices = zeros(numOfParamsToSample,numOfParamsToSample,samplesToDraw);   
            
            %calculate the current information
            currentInfo = model.calcGradInformation(startParams,data,proposal.RequiredInfo);
            
            t=tic;
            %sampling loop 
            for sampleNo=1:samplesToDraw
                
                if sampleNo == RosenthalAdaptiveSampler.StartAdaption && isa(proposal,'RwmhMixtureProposal')
                     %need to set the mixture sampling for this sampler
                     proposal.mixture=1;
                elseif sampleNo > RosenthalAdaptiveSampler.StartAdaption 
                    %start using the mixture distribution to draw posterior
                    %samples
                    try
                        proposal.mass_matrix=scaleFactor*covarianceMatrix;
                    catch Exception
                        disp(Exception)
                        disp(sampleNo)
                    end
                else
                    covarianceMatrix=eye(model.k,model.k);
                    proposal.mass_matrix=scaleFactor*covarianceMatrix;
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

                if sampleNo > RosenthalAdaptiveSampler.StartAdaption
                    %start estimating the covariance matrix using the previous
                    %samples
                    covarianceMatrix=cov(paramSamples(:,1:sampleNo)');
                end
                matrices(:,:,sampleNo) = covarianceMatrix;
                
                %tuning step
                scaleFactors(sampleNo)=scaleFactor;
                if(sampleNo <= burnIn && sampleNo>=burninAdjustLag)
                    if mod(sampleNo,burninAdjustLag) == 0
                        acceptanceProportion = sum(acceptances(sampleNo-burninAdjustLag+1:sampleNo))/burninAdjustLag;
                        if acceptanceProportion < samplerParams.LowerAcceptanceLimit
                            scaleFactor=scaleFactor*(1-samplerParams.ScaleFactor);        
                            fprintf('Acceptance: %d Scale factor decreased to %.8f at %d iterations\n',acceptanceProportion,scaleFactor,sampleNo)
                        elseif acceptanceProportion > samplerParams.UpperAcceptanceLimit
                            scaleFactor=scaleFactor*(1+samplerParams.ScaleFactor);
                            fprintf('Acceptance: %d Scale factor  increased to %.8f at %d iterations\n',acceptanceProportion,scaleFactor,sampleNo)
                        end

                    end
                end
                
                %notification output
                if mod(sampleNo, userNotify) == 0
                    fprintf('%d steps performed. Last acceptance=%d, Log-posterior = %d scale= %d\n',sampleNo,sum(acceptances(sampleNo-userNotify+1:sampleNo))/userNotify,posteriors(sampleNo),scaleFactor)
                    fprintf('Current parameter values = %s\n', sprintf('%.2d ',paramSamples(:,sampleNo)))
                    disp(covarianceMatrix)
                end                       
                
            end
            
            %return samples. Transpose paramSamples and proposals to make
            %tham easier to read
            sampleTime=toc(t); 
            samples=struct('covariance', matrices,'params',paramSamples','N', samplesToDraw,'acceptances',acceptances,'posteriors',posteriors,'proposals',proposals','sampleTime',sampleTime,'mass_matrix',proposal.mass_matrix, 'scaleFactors', scaleFactors);
                       
        end

        
    end
    
    
end