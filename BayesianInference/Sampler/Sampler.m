classdef Sampler
    %SAMPLER - a class which has two static methods with which to perform
    %MCMC sampling. Sampling is either performed jointly (blockSample), or
    %componentwise (cwSample)
    
    methods (Static)
        function samples = blockSample(samplerParams,model,data,proposal,startParams)
            
            %INPUTS
            %samplerParams - a stucture of sampling parameters
            %model - contains the model specification and likelihood
            %data - the data required to evaluate the model likelihood
            %proposal - Proposal object contains function to use as a proposal,
            %startParams - starting values for the parameters

            %OUTPUTS
            %samples - a structure containing the samples, acceptances etc.
            
            %Samples parameters in a single block
            numOfParamsToSample=model.k;
            samplesToDraw = samplerParams.Samples;
            burninSteps = samplerParams.Burnin;
            burninAdjustLag = samplerParams.AdjustmentLag;
            userNotify = samplerParams.NotifyEveryXSamples;
            scaleFactors= ones(samplesToDraw,1);
            scaleFactor=1;
            
            %datastructures for sampling   
            paramSamples=zeros(numOfParamsToSample,samplesToDraw);
            proposals=zeros(numOfParamsToSample,samplesToDraw);            
            acceptances = zeros(samplesToDraw,1);
            posteriors=zeros(samplesToDraw,1);
            
            %calculate the current likelihood
            %currLikelihood=model.calcLogLikelihood(startParams,data);
            currentInfo = model.calcGradInformation(startParams,data,proposal.RequiredInfo);
            t=tic();
            
            %sampling loop 
            for sampleNo=1:samplesToDraw
                %paramSamples(sampleNo,:)=;
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
                    posteriors(sampleNo)=currentInfo.LogPosterior;                     
                end
                
                %tuning step for sampler
                scaleFactors(sampleNo)=scaleFactor;
                if(sampleNo <= burninSteps && sampleNo>=burninAdjustLag )

                    if mod(sampleNo,burninAdjustLag) == 0
                        acceptanceProportion = sum(acceptances(sampleNo-burninAdjustLag+1:sampleNo))/burninAdjustLag;
                        if acceptanceProportion < samplerParams.LowerAcceptanceLimit
                            scaleFactor=scaleFactor*(1-samplerParams.ScaleFactor);
                            proposal = proposal.adjustScaling(1-samplerParams.ScaleFactor);        
                            fprintf('Acceptance: %d Scale factor decreased to %.8f at %d iterations\n',acceptanceProportion,scaleFactor,sampleNo)
                        elseif acceptanceProportion > samplerParams.UpperAcceptanceLimit
                            scaleFactor=scaleFactor*(1+samplerParams.ScaleFactor);
                            proposal = proposal.adjustScaling(1+samplerParams.ScaleFactor);
                            fprintf('Acceptance: %d Scale factor  increased to %.8f at %d iterations\n',acceptanceProportion,scaleFactor,sampleNo)
                        end
                    end
                end
                                      
                %notification output
                if mod(sampleNo, userNotify) == 0
                    %update printing
                    fprintf('%d steps performed. Last acceptance=%d, Log-posterior = %d scale= %d\n',sampleNo,sum(acceptances(sampleNo-userNotify+1:sampleNo))/userNotify,posteriors(sampleNo),scaleFactor)
                    fprintf('Current parameter values = %s\n', sprintf('%.4f ',paramSamples(:,sampleNo)))
                end                     
                
            end
            
            %return samples. Transpose paramSamples and proposals to male
            %tham easier to read
            sampleTime=toc(t);
            samples=struct('params',paramSamples','N', samplesToDraw,'acceptances',acceptances,'posteriors',posteriors,'proposals',proposals','scaleFactors',scaleFactors,'sampleTime', sampleTime);
            
            
        end
        
        function samples = cwSample(samplerParams,model,data, proposal,startParams)
            %CWSAMPLE - Samples parameters one by one to improve mixing
            
            %INPUTS
            %samplerParams - a stucture of sampling parameters
            %model - contains the model specification and likelihood
            %data - the data required to evaluate the model likelihood
            %proposal - Proposal object contains function to use as a proposal,

            %OUTPUTS
            %samples - a structure containing the samples, acceptances etc.
            
            numOfParamsToSample=model.k;
            samplesToDraw = samplerParams.Samples;
            burninSteps = samplerParams.Burnin;
            burninAdjustLag = samplerParams.AdjustmentLag;
            userNotify = samplerParams.NotifyEveryXSamples;
            scaleFactors=ones(model.k,1);
            runningSF = ones(model.k,samplesToDraw);
            
            %datastructures for sampling   
            paramSamples=zeros(numOfParamsToSample,samplesToDraw);
            proposals=zeros(numOfParamsToSample,samplesToDraw);
            
            %individually sampled params
            acceptances = zeros(numOfParamsToSample,samplesToDraw);
            posteriors=zeros(numOfParamsToSample,samplesToDraw);

            %calculate the current likelihood
            currentInfo = model.calcGradInformation(startParams,data,proposal.RequiredInfo);
            
            t=tic();
            %sampling loop 
            for sampleNo=1:samplesToDraw
                
                %sample the parameters one at a time
                for param=1:numOfParamsToSample
                    [alpha,propParams,propInfo] = proposal.proposeCw(model,data,startParams,param,currentInfo);
                    proposals(param,sampleNo) = propParams(param);

                    if alpha == 0 || alpha > log(rand)                      
                        acceptances(param,sampleNo)=1;
                        posteriors(param,sampleNo)=propInfo.LogPosterior;
                        currentInfo=propInfo;
                        paramSamples(param,sampleNo)=propParams(param);
                        startParams=propParams;
                    else                        
                        paramSamples(param,sampleNo)=startParams(param);                       
                        posteriors(param,sampleNo)=currentInfo.LogPosterior;                     
                    end

                    %tuning step for sampler
                    runningSF(param,sampleNo) = scaleFactors(param);

                    if(sampleNo <= burninSteps && sampleNo>=burninAdjustLag )
                        if mod(sampleNo,burninAdjustLag) == 0
                            acceptanceProportion = sum(acceptances(param,sampleNo-burninAdjustLag+1:sampleNo))/burninAdjustLag;
                            if acceptanceProportion < samplerParams.LowerAcceptanceLimit
                                scaleFactors(param) = scaleFactors(param)*(1-samplerParams.ScaleFactor);
                                proposal=proposal.adjustPwScaling(1-samplerParams.ScaleFactor,param);   
                                fprintf('Acceptance: %d Scale factor decreased at %d iterations for param %i to %.3f\n',acceptanceProportion,sampleNo,param,scaleFactors(param))
                            elseif acceptanceProportion > samplerParams.UpperAcceptanceLimit
                                scaleFactors(param) = scaleFactors(param)*(1+samplerParams.ScaleFactor);
                                proposal=proposal.adjustPwScaling(1+samplerParams.ScaleFactor,param);
                                fprintf('Acceptance: %d Scale factor increased at %d iterations for param %i to %.3f\n',acceptanceProportion,sampleNo,param ,scaleFactors(param))
                            end
                        end
                    end
                end
                                      
                %notification output
                if mod(sampleNo, userNotify) == 0
                    fprintf('%d steps performed. Last global acceptance=%d, Log-posterior = %d \n',sampleNo,sum(sum(acceptances(:,sampleNo-userNotify+1:sampleNo)))/(userNotify*numOfParamsToSample),posteriors(sampleNo))
                    fprintf('Current parameter scalings = %s\n',sprintf('%.4f ',scaleFactors))
                    fprintf('Current parameter values = %s\n', sprintf('%.4f ',paramSamples(:,sampleNo)))
                end                     
                
            end
            
            %return samples. Transpose paramSamples and proposals to male
            %tham easier to read
            sampleTime=toc(t);
            samples=struct('params',paramSamples','N', samplesToDraw,'acceptances',acceptances','posteriors',posteriors','proposals',proposals','sampleTime',sampleTime,'scaleFactors',runningSF);
                        
        end
    end
end
