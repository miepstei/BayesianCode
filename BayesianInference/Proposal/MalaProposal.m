classdef MalaProposal < Proposal
    %MalaProposal makes proposals based on a mala scheme with mass matrix
    %   Detailed explanation goes here
    
    properties(Constant)
         RequiredInfo = [1 1 0 0];
    end    
    
    properties(Access=public)
        mass_matrix; % k*k covariance matrix
        epsilon;    % scalar step-size
        componentwise = 0; %update must be joint
    end
       
    methods
        function obj = set.mass_matrix(obj,mass_m)
            [~, p] = chol(mass_m);   
            if(p == 0)
                obj.mass_matrix = mass_m;
            else
                error('MalaProposal:mass_matrix:notPosDef','mass matrix must be positive definite')
            end              
        end
        
        function obj = set.epsilon(obj, eps)
            %epsilon cannot be <= 0 
            if eps <= 0
                error('MalaProposal:epsilon:Negative','epsilon must be positive')
            else
                obj.epsilon = eps; 
            end
        end
        
    end
    
    methods(Access=public)
        function obj=MalaProposal(mass_m, epsilon)
            obj.mass_matrix=mass_m;
            obj.epsilon = epsilon;
        end
        
        
        function [alpha,propParams,propInfo] = propose(obj,model,data,currentParams,currInfo)
            
            % PROPOSE  Proposes a MALA step for the parameters of a model.
            % The epsilon and mass matrix are set in the construction of the
            % MalaSampler
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
            
             
            
            propMeans  = currentParams + 0.5*obj.epsilon*obj.mass_matrix*currInfo.GradLogPosterior;
            % remember L'*L=obj.epsilon^2*obj.mass_matrix;
            L = chol(obj.epsilon*obj.mass_matrix);
            
            propParams = propMeans + (L' * randn(length(currentParams),1));
            propInfo = model.calcGradInformation(propParams,data,TruncatedMalaProposal.RequiredInfo);                    
            
            if propInfo.LogPosterior ~= -Inf
                
                %q(\theta^* \mid \theta)
                newGivenOld =-sum(log(diag(L)))-0.5*(propParams-propMeans)'*((obj.mass_matrix^-1)/obj.epsilon)*(propParams-propMeans);
                
                %q(\theta \mid \theta^*)
                newPropMeans = propParams + 0.5*obj.epsilon*obj.mass_matrix*propInfo.GradLogPosterior;
                oldGivenNew = -sum(log(diag(L)))-0.5*(currentParams - newPropMeans)'*((obj.mass_matrix^-1)/obj.epsilon)*(currentParams-newPropMeans);
                
                alpha = min(0,((propInfo.LogPosterior+oldGivenNew)-(currInfo.LogPosterior+newGivenOld)));
            else
                %no point computing alpha if move is impossible
                alpha=-Inf;
            end  
        end
        
        function obj=adjustScaling(obj,factor)
            obj.epsilon=obj.epsilon*factor;
        end
               
    end
    
end

