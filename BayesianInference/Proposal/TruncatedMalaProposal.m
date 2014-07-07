classdef TruncatedMalaProposal < Proposal
    %MalaProposal makes proposals based on a mala scheme with mass matrix
    %   Detailed explanation goes here
    
    properties(Access=public)
        mass_matrix; % k*k covariance matrix
        epsilon;    % scalar step-size
        componentwise = 0; %update must be joint
        truncation; %truncation factor for mala step
    end

    properties(Constant)
        RequiredInfo = [1 1 0 0];
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
        
        function obj = set.truncation(obj, trunc)
            if trunc <= 0
                error('MalaProposal:truncation:Negative','truncation factor must be positive')
            else
                obj.truncation = trunc; 
            end            
        end      
    end
    
    methods(Access=public)
        function obj=TruncatedMalaProposal(mass_m, epsilon,truncation)
            obj.mass_matrix=mass_m;
            obj.epsilon = epsilon;
            obj.truncation=truncation;
        end
        
        
        function [alpha,propParams,propInfo] = propose(obj,model,data,currentParams,currInfo)
            
            % PROPOSE  Proposes a truncated MALA step for the parameters of a model.
            % The epsilon and mass matrix are set in the construction of the
            % MalaSampler
            %
            %   OUTPUTS 
            %   alpha - scalar, log probability of the proposed move
            %   propParams - k * 1 vector of proposed parameters
            %   currInfo - structure, logPosterior and gradLogPosterior of
            %   current position
            %   
            %   INPUTS
            %
            %   model - Object, a statistical model of type Model
            %   data - struct, a representation that the model understands
            %   propInfo, structure, logPosterior and gradLogPosterior of
            %   proposed position
            
            
            %sample based on first-order gradient information
            truncation_factor = obj.truncation/max(obj.truncation,norm(currInfo.GradLogPosterior));
            propMeans  = currentParams + (0.5*obj.epsilon)*obj.mass_matrix * truncation_factor*currInfo.GradLogPosterior;
            
            L = chol(obj.epsilon*obj.mass_matrix);
            % remember L'*L=obj.epsilon*obj.mass_matrix;
            
            propParams = propMeans + (L' * randn(length(currentParams),1));
            propInfo = model.calcGradInformation(propParams,data,TruncatedMalaProposal.RequiredInfo);

            if propInfo.LogPosterior ~= -Inf &&  ~isnan(propInfo.LogPosterior)
                %accept/reject ratio needs to take account of asymmetry in
                %proposal distibution
                
                %q(\theta^* \mid \theta)
                %newGivenOld = log(mvnpdf(propParams,propMeans ,obj.epsilon*obj.mass_matrix));
                newGivenOld =-sum(log(diag(L)))-0.5*(propParams-propMeans)'*(obj.mass_matrix^-1/(obj.epsilon))*(propParams-propMeans);
                new_truncation_factor = obj.truncation/max(obj.truncation,norm(propInfo.GradLogPosterior));
                
                %q(\theta \mid \theta^*)
                %oldGivenNew = log(mvnpdf(currentParams,newPropMeans ,obj.epsilon*obj.mass_matrix));
                newPropMeans = propParams + (0.5*obj.epsilon)*obj.mass_matrix*new_truncation_factor*propInfo.GradLogPosterior;
                oldGivenNew = -sum(log(diag(L)))-0.5*(currentParams - newPropMeans)'*(obj.mass_matrix^-1/(obj.epsilon))*(currentParams-newPropMeans);

                alpha = min(0,((propInfo.LogPosterior+oldGivenNew)-(currInfo.LogPosterior+newGivenOld)));

            else
                alpha=-Inf;
            end
        end
        
        function obj=adjustScaling(obj,factor)
            obj.epsilon=obj.epsilon*factor;
        end
        
    end
    
end