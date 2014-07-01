classdef (Abstract) Proposal
    properties(Abstract)
        componentwise %whether the sampler should be joint or per parameter
         
    end
    properties(Constant,Abstract)
        RequiredInfo %what information (ie derivative information) is required by the sampler
    end
    
    methods(Abstract)
        %proposal method to be implemented by subclasses
        % PROPOSE  Proposes a MCMC step for the parameters of a model
        %
        %   OUTPUTS 
        %   alpha - scalar, log probability of the proposed move
        %   propParams - k * 1 vector of proposed parameters
        %   propLikelihood - scalar, log likelihood of proposed move
        %   currLikelihood - scalar, log likelihood of current position
        %   
        %   INPUTS
        %
        %   model - Object, a statistical model of type Model
        %   data - struct, a representation that the model understands
        %   currentParams, k * 1 vector of current param position 

        [alpha,propParams,propInformation] = propose(obj,experiment,data,currentParams,currentInformation)
        
        %adjust the step-size, implementation depends on the sampler
        adjustScaling(factor)
    end
end