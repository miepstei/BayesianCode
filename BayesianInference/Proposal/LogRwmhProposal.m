classdef LogRwmhProposal < Proposal
    %RwmhProposal - Random-walk Metropolis Hastings proposal step
    
    
    properties
        mass_matrix;
        componentwise = 0;
    end
    
    properties(Constant)
        RequiredInfo = [1 0 0 0];
    end
    
    
    methods
        function obj = LogRwmhProposal(mass_matrix,compFlag)
            obj.mass_matrix = mass_matrix;
            obj.componentwise = compFlag;
        end
        
            
        function obj = set.componentwise(obj,cw) 
            if (cw ~= 0 && cw ~=1 )
                error('RwmhProposal:componentwise:invalidComponent', 'componentwise parameter must be 0 or 1')
            end
            obj.componentwise = cw;
        end
        
        function obj = set.mass_matrix(obj,mass_matrix)
            %must be positive definite
            [~, p] = chol(mass_matrix);         
            if(p == 0)
                obj.mass_matrix = mass_matrix;
            else
                error('RwmhProposal:mass_matrix:notPosDef','covariance matrix must be positive definite')
            end    
    
        end
        
        function [alpha,propParams,propInformation] = propose(obj,model,data,currentParams,currInfo)

            % PROPOSE  Proposes a joint metropolis-hastings step for the parameters of a model.
            %
            %   OUTPUTS 
            %   alpha - scalar, log probability of the proposed move
            %   propParams - k * 1 vector of proposed parameters
            %   propInformation - Information of the move (logPosterior only for rwmh)
            
            %   
            %   INPUTS
            %
            %   model - Object, a statistical model of type Model
            %   data - struct, a representation that the model understands
            %   currentParams, k * 1 vector of current param position
            %   currentInformation, structure current information,
            %   (logPosterior)
                        
            %logCurrentParams = log10(currentParams);
            [L, ~] = chol(obj.mass_matrix);
            logPropParams = log(currentParams) + L' * randn(length(currentParams),1);
            propInformation = model.calcGradInformation(exp(logPropParams),data,RwmhProposal.RequiredInfo);
                

            if isinf(propInformation.LogPosterior)
                alpha=-Inf;
            else               
                %need to transform the density in log space to ensure mass
                %is equivalent in log space
                alpha = min(0,(propInformation.LogPosterior + log(prod(exp(logPropParams))))-(currInfo.LogPosterior +log(prod(exp(currentParams)))));
            end
            propParams=exp(logPropParams);    

        end 

        function [alpha,propParams,propInformation] = proposeCw(obj,model,data,currentParams,iP,currentInformation)

            % PROPOSE  Proposes a componentwise metropolis-hastings step for the parameter of a model.
            %
            %   OUTPUTS 
            %   alpha - scalar, log probability of the proposed move
            %   propParams - k * 1 vector of proposed parameters
            %   propInformation - Information of the move (logPosterior only for rwmh)
            %   
            %   
            %   INPUTS
            %
            %   model - Object, a statistical model of type Model
            %   data - struct, a representation that the model understands
            %   currentParam - k * 1 vector of current param position
            %   iP - scalar, the index of the parameter to sample
            %   currentInformation, structure current information,
            %   (logPosterior)
                        
             
            propParams=currentParams;
            
            propParams(iP) = exp(normrnd(log(currentParams(iP)),obj.mass_matrix(iP,iP)));
            propInformation = model.calcGradInformation(propParams,data,RwmhProposal.RequiredInfo);
                        
            %proposal distibution is symmetric so cancels in the ratio
            if isinf(propInformation.LogPosterior)
                alpha=-Inf;
            else
                alpha = min(0,(propInformation.LogPosterior + log(prod(propParams)))-(currentInformation.LogPosterior +log(prod(currentParams))));
            end
        end         
        
        function obj=adjustScaling(obj,factor)
            %scale diagonal elements of the mass matrix
            obj.mass_matrix(logical(eye(size(obj.mass_matrix))))=diag(obj.mass_matrix)*factor;
        end
        
        function obj=adjustPwScaling(obj,factor,paramNo)
            obj.mass_matrix(paramNo,paramNo)=obj.mass_matrix(paramNo,paramNo)*factor;
        end
        
    end  
end
