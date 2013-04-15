classdef State
    %encapsulates a state of a given mechanism
    
    properties
        type
        name
        conductance
        ord
        no=0
    end
    
    methods
        function obj=State(t,na,c,ord,no)
           obj.type=t; 
           obj.name=na;
           obj.conductance=c;
           obj.ord=ord; %explicit order the state should appear
        end
        
       
        function name=get.name(obj)
            name=obj.name;
        end
        
        function cond=get.conductance(obj)
           cond=obj.conductance; 
        end
        
    end
    
    
    
end

