classdef SimulatedScnHeader < ScnHeader
    
   properties(Access=private)
        treso;
        tresg;
   end
    
    
   
    methods
        function obj = SimulatedScnHeader(version,offset,n_int,title,date,tapeID,i_patch,emem,avamp,rms,ffilt,calfac2,treso,tresg)
            obj@ScnHeader(version,offset,n_int,title,date,tapeID,i_patch,emem,avamp,rms,ffilt,calfac2);
            obj.treso = treso;
            obj.tresg = tresg;
    
        end
        
    end
    
    methods(Static)
        function s=toString(obj)
           %state of the header
           s=toString@ScnHeader(obj);
           s=strcat(s, 'treso: ' , num2str(obj.treso) , '\n', ...
           'tresg: ' , num2str(obj.tresg) , '\n');     
        end
    end
    
    
end