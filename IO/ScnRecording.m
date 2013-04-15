classdef ScnRecording
    
    properties
        intervals;
        amplitudes;
        status;
        points;
    end
    
    properties(Constant)
       STATUS_BAD=8;
       STATUS_GOOD=0;
    end
    
    methods
        function obj = ScnRecording(intervals,amplitudes,status,points)
            if(nargin > 0)
                obj.intervals=intervals;
                obj.amplitudes=amplitudes;
                obj.status=status;
                obj.points=points;
            end
        end
        
        function index=getFirstShutIntervalGreaterThan(obj,t_crit)
            index = find(obj.intervals>t_crit, 1);
        end
        
        function indices=getShutIntervalGreaterThan(obj,t_crit)
            indices = intersect(find(obj.intervals>t_crit),find(obj.amplitudes==0));
        end
        
        function newObj = getIntervals(obj,oc)
            if oc == 0;
                idx = obj.amplitudes==0;
            else
                idx = obj.amplitudes>0;
            end
            
            amps = obj.amplitudes(idx);
            stats = obj.status(idx);
            ints = obj.intervals(idx);
            pts = length(amps);
            newObj= ScnRecording(ints,amps,stats,pts);
        end
        
        function amps=getAmps(obj,start,finish)
            amps = obj.amplitudes(start:finish);
        end
            
        function amp = getAmpAt(obj,idx)
            amp = obj.amplitudes(idx);
        end
        
        
        function statuses=getStatuses(obj,start,finish)
            statuses = obj.status(start:finish);
        end
        
        function status = getStatusAt(obj,idx)
            status = obj.status(idx);
        end
        
        function ints=getInts(obj,start,finish)
            ints = obj.intervals(start:finish);
        end
        
        function interval = getIntervalAt(obj,idx)
            interval = obj.intervals(idx);
        end
        
        function points = getPoints(obj)
            points = obj.points;
        end
        
        function setStatusAt(obj,idx,val)
            obj.status(idx)=val;
        end
        
        function setAmpAt(obj,idx,val)
            obj.amp(idx)=val;
        end
        
        function setIntervalAt(obj,idx,val)
            obj.intervals(idx)=val;
        end
        
        function setNegativeIntervals(obj)
            %if we have any negative intervals in the code set then to
            %unusable
            obj.status(obj.intervals<0)=ScnRecording.STATUS_BAD;
        end
        
        
        function s=toString(obj)
           %state of the header
           s=strcat('ScnRecording Numbers of ... \nIntervals: ' , num2str(length(obj.intervals)) , '\n', ...
            'Offset: ' , num2str(length(obj.amplitudes)) , '\n', ...
            'Status: ' , num2str(length(obj.status)) , '\n', ...
        'Number of intervals ', num2str(obj.getPoints));
        end
    end
    
    
end