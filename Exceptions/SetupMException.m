classdef SetupMException < MException
    
	properties (Dependent = true)
		ExceptionObject;
    end
    
	properties (Access=public)
		params;
	end    
	methods
		function obj = SetupMException(identifier,message,badparams)
			obj = obj@MException(identifier,message);
            obj.params = badparams;
		end
		function val = get.ExceptionObject(obj)
			val.message = obj.message;
		end
	end
end