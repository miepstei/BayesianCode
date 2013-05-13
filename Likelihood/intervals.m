classdef intervals < handle               % subclass handle
    properties
       t
       % data stored at the node
    end
    methods
        function obj = intervals(min,max)
            obj;
            obj.t=struct([]);

        end
        
        function add(obj,min,max)
            root_int=length(obj.t)+1;
            obj.t(root_int).min = min;
            obj.t(root_int).max = max;  
        end
        
        function ints = convert(obj)
           %converts object to 2 by n object for comparison with dc-pyps
           ints=zeros(length(obj.t),2);
           for i=1:size(ints,1)
              ints(i,1)=obj.t(i).min; 
              ints(i,2)=obj.t(i).max;
           end 
           ints=sort(ints,1);
        end
    end
end

