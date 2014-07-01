classdef SimpMmalaProposalDecomp < Proposal
    
    properties(Constant)
         RequiredInfo = [1 1 1 0];
    end    
    
    properties(Access=public)
        epsilon
        componentwise = 0;%can not be pairwise with this sampler
    end
        
    
    methods
        function obj = set.epsilon(obj, eps)
            %epsilon cannot be <= 0 
            if eps <= 0
                error('MmalaProposal:epsilon:Negative','epsilon must be positive')
            else
                obj.epsilon = eps; 
            end
        end 
    end
    methods(Access=public)
        
        function obj=SimpMmalaProposalDecomp(varargin)
            if nargin>0
                obj.epsilon=varargin{1}; 
            else
                obj.epsilon=1;
            end
        end
        
        function [alpha,propParams,propInfo] = propose(obj,model,data,currentParams,currInfo)
                      

            %proposal with simplified mala assumes the curvature at the
            %local position is constant
            
            %\theta^* = \theta +
            %\frac(\epsilon^2}{2}\+{G}^-1(\theta)\div(\theta) + \epsilon
            %\sqrt{\+{G}^{-1}(\theta)}\+{z}
                       
            %check hessian is valid metric tensor
            %[L, p] = chol(obj.epsilon*invG);
                 
            [s,d]= eig(currInfo.MetricTensor,'nobalance');
            currInfo.MetricTensor=(s*abs(d)*s^(-1) + (1/obj.epsilon)*eye(model.k,model.k));
            invG = currInfo.MetricTensor^(-1);
            [L, ~] = chol(invG);
   
            propMeans = currentParams + 0.5*invG*currInfo.GradLogPosterior;
            propParams = propMeans + (L' * randn(length(currentParams),1));
            propInfo = model.calcGradInformation(propParams,data,SimpMmalaProposalDecomp.RequiredInfo);       

            if isinf(propInfo.LogPosterior)  
                alpha=-Inf;
            else
                
                % Q(new | old)
                % out by a factor of -log(2*pi) but cancels in the ratio
                % first term is determinant of G, required as metric
                % tensors are position-specific
                %newGivenOld = log(mvnpdf(propParams,propMeans ,obj.epsilon*invG));
                newGivenOld = -sum(log(diag(L)))-0.5*(propParams-propMeans)'*currInfo.MetricTensor*(propParams-propMeans);
                %calculate the new gradient information and proposal means based on the
                %proposed parameters
                                                     
                if any(isnan(propInfo.GradLogPosterior(:))) || any(isnan(propInfo.MetricTensor(:)))
                    alpha = -Inf;                 
                else
                    [s,d]= eig(propInfo.MetricTensor,'nobalance');
                    propInfo.MetricTensor=(s*abs(d)*s^(-1) + (1/obj.epsilon)*eye(model.k,model.k));
                    invGnew = propInfo.MetricTensor^(-1);                

                    propNewMeans = propParams + 0.5*invGnew*propInfo.GradLogPosterior;

                    % Q(old | new)
                    %oldGivenNew = log(mvnpdf(currentParams,propNewMeans ,obj.epsilon*invGnew));
                    oldGivenNew =-sum(log(diag(chol(invGnew))))-0.5*(propNewMeans-currentParams)'*propInfo.MetricTensor*(propNewMeans-currentParams);                
                    alpha = min(0,((propInfo.LogPosterior+oldGivenNew)-(currInfo.LogPosterior+newGivenOld)));%+(log(prob_a)-log(prob_b)));
                end 
            end
            
        end
        
        function obj = adjustScaling(obj,factor)
            obj.epsilon=obj.epsilon*factor;
        end
        
        function scaling = getScaling(obj)
            scaling=obj.epsilon;
        end
    end
    
end