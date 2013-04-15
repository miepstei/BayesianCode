classdef TransitionRate
    
    properties
        rate_constant 
        state_from %state object
        state_to %state object
        name
        eff='';
        fixed=false;
        mr=false; %fixed by microscopic reversibility
        funct=@(rate,y)rate; %by default just returns the rate
        limits=[]
        hasLimits=false;
        rate_id; %unique identifier for the rate
    end
   
   
    methods
        function obj = TransitionRate(const,from,to,name,eff,id)%eff,fixed,mr,funct,is_conc,is_func,constrain_args)
            obj.rate_constant=const;
            obj.state_from=from;
            obj.state_to=to;
            obj.name=name;
            obj.eff=eff;
            obj.rate_id=id;
        end
        
        function state_from = get.state_from(obj)
            state_from=obj.state_from;     
        end
        
        function state_to = get.state_to(obj)
            state_to=obj.state_to;     
        end
        
        %set optional params separaetly
        function obj = set.eff(obj,eff)
            %TODO: CHECK this is a single length list
            obj.eff=eff;
        end
        
        function eff = get.eff(obj)
            eff = obj.eff;
        end
        
        function obj = set.fixed(obj,fixed)
            obj.fixed=fixed;
        end
        
        function obj = set.mr(obj,mr)
            obj.mr=mr;
        end
        
        function obj = set.hasLimits(obj,bool)
            obj.hasLimits=bool;
        end
        
        function obj = set.funct(obj,funct)
            obj.funct=funct;
        end
              
        
        function obj = set.limits(obj,lim)
            %TODO: error check these as they come in...
            obj.limits=lim;
        end
        
        
        function obj=validateRateConstants(obj)
            if obj.limits(1) > obj.rate_constant
                 obj.rate_constant = obj.limits(1);
            end              
            
            if  obj.limits(2) < obj.rate_constant
                 obj.rate_constant = obj.limits(2);
            end
            
        end
        
        function validateFunction(obj)
            %TODO
            %if(isempty(funct)
            
            
        end
        
    end
    
end