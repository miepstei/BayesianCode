classdef SimpMmalaProposal < Proposal
 
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
        
        function obj=SimpMmalaProposal(varargin)
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
            
            invG = currInfo.MetricTensor^(-1);
            
            %check hessian is valid metric tensor
            [L, p] = chol(obj.epsilon*invG);
            
            if (p ~= 0)
                disp('Matrix is not positive semi-definite, eigenboosting')
                [~,d]= eig(currInfo.MetricTensor,'nobalance');
                currInfo.MetricTensor=(abs(min(diag(d)))+0.00001)*eye(model.k,model.k);
                invG = currInfo.MetricTensor^(-1);
                [L, p] = chol(invG*obj.epsilon);                
                if (p ~= 0)
                   error('invG  is still not positive semi-definite...aborting...') 
                end                
            end
            
            propMeans = currentParams + 0.5*obj.epsilon*invG*currInfo.GradLogPosterior;       
            propParams = propMeans + (L' * randn(length(currentParams),1));
            propInfo = model.calcGradInformation(propParams,data,SimpMmalaProposal.RequiredInfo);   

            if isinf(propInfo.LogPosterior)  
                alpha=-Inf;
            else
                % Q(new | old)
                % out by a factor of -log(2*pi) but cancels in the ratio
                % first term is determinant of G, required as metric
                % tensors are position-specific
                
                %newGivenOld = log(mvnpdf(propParams,propMeans ,obj.epsilon*invG));
                newGivenOld = -sum(log(diag(L)))-0.5*(propParams-propMeans)'*(currInfo.MetricTensor/obj.epsilon)*(propParams-propMeans);
                propInfo = model.calcGradInformation(propParams,data,SimpMmalaProposal.RequiredInfo);

                %calculate the new gradient information and proposal means based on the
                %proposed parameters

                invGnew = propInfo.MetricTensor^(-1);
                
                [~, p] = chol(obj.epsilon*invGnew);
                if (p ~= 0)
                    disp('Matrix is not positive semi-definite, eigenboosting')
                    [~,d]= eig(propInfo.MetricTensor,'nobalance');
                    propInfo.MetricTensor=(abs(min(diag(d)))+0.00001)*eye(model.k,model.k);
                    invGnew = propInfo.MetricTensor^(-1);
                    [~, p] = chol(invGnew*obj.epsilon);                
                    if (p ~= 0)
                       error('invG  is still not positive semi-definite...aborting...') 
                    end                     
                    
                end
                propNewMeans = propParams + 0.5*obj.epsilon*invGnew*propInfo.GradLogPosterior;
                
                % Q(old | new)
                
                %oldGivenNew = log(mvnpdf(currentParams,propNewMeans ,obj.epsilon*invGnew));
                oldGivenNew =-sum(log(diag(chol(invGnew*obj.epsilon))))-0.5*(propNewMeans-currentParams)'*(propInfo.MetricTensor/obj.epsilon)*(propNewMeans-currentParams);
                alpha = min(0,((propInfo.LogPosterior+oldGivenNew)-(currInfo.LogPosterior+newGivenOld)));
            end                         
            
        end
        
        function obj = adjustScaling(obj,factor)
            obj.epsilon=obj.epsilon*factor;
        end
        
    end
    
end