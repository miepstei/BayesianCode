classdef RwmhMixtureProposal < Proposal
    %RwmhProposal - Random-walk Metropolis Hastings proposal step
    
    properties(Constant)
         RequiredInfo = [1 0 0 0];
    end
    
    properties
        mass_matrix;
        componentwise = 0;
        beta=0.05;
        mixture = 0;
        epsilon=1;
    end
    
    methods
        function obj = RwmhMixtureProposal(mass_matrix,compFlag)
            obj.mass_matrix = mass_matrix;
            obj.componentwise = compFlag;
        end
        
            
        function obj = set.componentwise(obj,cw) 
            if (cw ~= 0 )
                error('RwmhProposal:componentwise:invalidComponent', 'componentwise parameter must be 0')
            end
            obj.componentwise = cw;
        end

        function obj = set.mixture(obj,mix) 
            if (mix ~= 0 && mix ~=1)
                error('RwmhProposal:mixture:invalidComponent', 'mixture parameter must be 0 or 1')
            end
            obj.mixture = mix;
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
        
        function obj = set.beta(obj,sbeta)
            if sbeta < 0 || sbeta > 1 
                 error('RwmhProposal:beta:invalid','beta must be between 0 and 1')
            else
                obj.beta = sbeta;
            end
        end
        
        function [alpha,propParams,propInfo] = propose(obj,model,data,currentParams,currInfo)

            % PROPOSE  Proposes a joint metropolis-hastings step for the
            % parameters of a model based on proposing from amixture
            % distribution
            %
            %   OUTPUTS 
            %   alpha - scalar, log probability of the proposed move
            %   propParams - k * 1 vector of proposed parameters
            %   propInfo - structure, logPosterior and gradLogPosterior of
            %   proposed position
            %   
            %   INPUTS
            %
            %   model - Object, a statistical model of type Model
            %   data - struct, a representation that the model understands
            %   currInfo, structure, logPosterior and gradLogPosterior of
            %   current position
                        
            
            if obj.mixture
                [L, ~] = chol(((2.38^2)/model.k)*obj.mass_matrix);
                mixture1 = (1-obj.beta)*(currentParams + (L' * randn(length(currentParams),1)));
                mixture2 = obj.beta* (currentParams +  ((0.1/sqrt(model.k))* randn(length(currentParams),1)));
                propParams = mixture1+mixture2;
            else
                propParams = currentParams+((0.1/sqrt(model.k))*randn(length(currentParams),1));
            end
                       
            propInfo = model.calcGradInformation(propParams,data,RwmhMixtureProposal.RequiredInfo);    
            %proposal distibution is symmetric so cancels in the ratio
            if isinf(propInfo.LogPosterior)
                alpha=-Inf;
            else
                alpha = min(0,((propInfo.LogPosterior)-(currInfo.LogPosterior)));
            end
        end 
       
        
        function obj=adjustScaling(obj,factor)
            %scale diagonal elements of the mass matrix
            obj.epsilon=obj.epsilon*factor;
            obj.mass_matrix(logical(eye(size(obj.mass_matrix))))=diag(obj.mass_matrix)*obj.epsilon;
        end
        
        
        function scaling= getScaling(obj)
            scaling=obj.epsilon;
        end

    end  
end

