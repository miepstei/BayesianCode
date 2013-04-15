classdef ScnHeader
   %base class for Scn Header
   
   properties(Access=private)
       version = 0;
       offset;
       n_int;
       title;
       tapeID;
       date;
       i_patch;
       emem;
       avamp;
       rms;
       ffilt;
       calfac2;
   end
    
    
    methods
        function obj = ScnHeader(version,offset,n_int,title,date,tapeID,i_patch,emem,avamp,rms,ffilt,calfac2)
           % class constructor
            if(nargin > 0)
                obj.version = version;
                obj.offset   = offset;
                obj.n_int    = n_int;
                obj.title  = title;
                obj.tapeID   = tapeID;
                obj.date = date;
                obj.i_patch = i_patch;
                obj.emem = emem;
                obj.avamp = avamp;
                obj.rms = rms;
                obj.ffilt = ffilt;
                obj.calfac2 = calfac2;
            end
        end
        
        function n_int = get_nint(obj)
           n_int=obj.n_int; 
        end
        
        function offset = get_offset(obj)
           offset=obj.offset; 
        end
        
    end
    
    methods(Static)
        function s=toString(obj)
           %state of the header
           s=strcat('Version: ' , num2str(obj.version) , '\n', ...
            'Offset: ' , num2str(obj.offset) , '\n', ...
            'n_int: ' , num2str(obj.n_int) , '\n', ...
            'title: ' , obj.title , '\n', ...
            'tapeID: ' , num2str(obj.tapeID) , '\n', ...
            'date: ' , obj.date , '\n', ...
            'i_patch: ' , num2str(obj.i_patch) , '\n', ...
            'emem: ' , num2str(obj.emem) , '\n', ...
            'avamp: ' , num2str(obj.avamp), '\n', ...
            'rms: ' , num2str(obj.rms) , '\n', ...
            'ffilt: ' , num2str(obj.ffilt) , '\n', ...
            'calfac2: ' , num2str(obj.calfac2), '\n');
        end
    end
    
   
end