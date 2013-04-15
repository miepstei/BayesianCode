classdef RecordingManipulator
    %RecordingManipulator responsible for data operations such
    %as imposing resolution and bursts and so on.
    
    properties(Constant)
        OPEN_AMP=1;
        CLOSED_AMP=0;
        EPSILON = 0.0000001;
    end
    
    
    methods(Static = true)
        
        function [open shut] = getPeriods(res_ts)
            % seperate the open-shut intervals into separate timeseries
            % this function may differ from the one in
            % dc-pyps. Basically in dc-pyps the code loops over the
            % resolved intervals. If the first interval is shut, it adds
            % it. If the first interval is open it keeps track of the open
            % period and then tacks it on only when the loop encounters
            % another shut period.
            
            % Basically the resolved method should take care of this
            % concatination of open and shut periods. Also, the last open
            % period is missed off. But not the last shut period.
            open = res_ts.getIntervals(RecordingManipulator.OPEN_AMP);
            shut = res_ts.getIntervals(RecordingManipulator.CLOSED_AMP);

        end
        
        function burst_array = getBursts(res_ts,t_crit)
            %this function returns a list of bursts from a resolved time
            %series for a given separable t_crit
            
            %the intervals of shut times > t_crit
            burst_intervals=getShutIntervalGreaterThan(res_ts,t_crit);
            %burst_array=[];
            %we want to create the bursts which pertain to between these
            %indices
            
            for interval=2:length(burst_intervals)
                %burst starts AFTER the initial long shut period
                burst_start=burst_intervals(interval-1)+1;
                
                %burst ends BEFORE the next long shutting
                burst_end = burst_intervals(interval)-1;
                
                %mean_amp=0; %mean open amplitude across the burst
                %open_burst=0; %open time during the burst
                %burst_length=0; %total time of the burst
                %indiv_open_length=[]; %individual open intervals 
                %openings=0; %number of openings during the burst
                                
                wb_amps = res_ts.getAmps(burst_start,burst_end);
                wb_intervals = res_ts.getInts(burst_start,burst_end);
                wb_status=res_ts.getStatuses(burst_start,burst_end);
                wb=struct('amps',wb_amps,'intervals',wb_intervals,'status',wb_status);
                
                openings=sum(wb_amps>0);
                indiv_open_length=wb_intervals(wb_amps>0);
                burst_length=sum(wb_intervals);
                open_burst=sum(wb_intervals(wb_amps>0));
                open_amps=wb_amps(wb_amps>0);
                mean_amp=sum(indiv_open_length.*open_amps)/openings;
                burst_status=sum(wb_status==ScnRecording.STATUS_BAD);
                burst=Burst(wb,openings,open_burst,burst_length,burst_status,indiv_open_length,mean_amp);
               
                %now create the burst
                burst_array(interval-1)=burst;
                
            end
            
            
        end
        
        function rts = imposeResolution(raw_ts,res)
            % Tis function imposes a resolution on a raw timeseries
            % raw_ts - timeseries to be resolved
            % res - resolution in milliseconds
            
            %some preliminaries
            
            %if the last element in raw_ts is closed then it is unusable
            points=raw_ts.getPoints();
            if raw_ts.getAmpAt(points) == 0
                raw_ts.setStatusAt(points,ScnRecording.STATUS_BAD);
            end
            
            raw_ts.setNegativeIntervals();
            
            index=1;
            found_period=false;
            
            while ~found_period
                if (raw_ts.getIntervalAt(index) > res) && (raw_ts.getStatusAt(index) ~= ScnRecording.STATUS_BAD)
                    found_period=true;
                    
                else    
                    index=index+1;
                end
            end
                                 
            resolved_intervals(1)=raw_ts.getIntervalAt(index);
            resolved_status(1)=raw_ts.getStatusAt(index);
            resolved_ampls(1)=  raw_ts.getAmpAt(index);
            
            curr_interval=resolved_intervals(1);
            curr_amp=resolved_ampls(1);
            sum_amp=curr_interval*curr_amp;
            
            %now look for and concatinate intervals that are < res
            
            for i=index+1:points
                if raw_ts.getIntervalAt(i) < res
                    %we want to concatinate this interval onto the current
                    %resolvable record.
                    resolved_intervals(end)=resolved_intervals(end)+raw_ts.getIntervalAt(i);
                    if raw_ts.getAmpAt(i) > 0 && resolved_ampls(end) > 0
                        %we calculate the average current for this open
                        %interval assuming that the resolved period is open
                        sum_amp=sum_amp+raw_ts.getAmpAt(i)*raw_ts.getIntervalAt(i);
                        curr_interval=curr_interval+raw_ts.getIntervalAt(i);
                        resolved_ampls(end)=sum_amp/curr_interval;
                    end
                        
                else
                    if abs(raw_ts.getAmpAt(i)) < RecordingManipulator.EPSILON && abs(resolved_ampls(end)) < RecordingManipulator.EPSILON
                        %tack the current closed period onto this one
                        resolved_intervals(end)=resolved_intervals(end)+raw_ts.getIntervalAt(i);                       
                    elseif (resolved_ampls(end) - raw_ts.getAmpAt(i)) < RecordingManipulator.EPSILON && resolved_ampls(end) > RecordingManipulator.EPSILON
                        %resolve the current amps and recalc the average
                        resolved_intervals(end)=resolved_intervals(end)+raw_ts.getIntervalAt(i);
                        sum_amp=sum_amp+raw_ts.getAmpAt(i)*raw_ts.getIntervalAt(i);
                        curr_interval=curr_interval+raw_ts.getIntervalAt(i);
                        resolved_ampls(end)=sum_amp/curr_interval;                       
                    else
                        %the channel is now closed when it was open. Create
                        %a new interval.
                        resolved_ampls(end+1) = raw_ts.getAmpAt(i);
                        resolved_status(end+1) = raw_ts.getStatusAt(i);
                        resolved_intervals(end+1) =raw_ts.getIntervalAt(i);
                        sum_amp = raw_ts.getIntervalAt(i) * raw_ts.getAmpAt(i);
                        curr_interval=raw_ts.getIntervalAt(i);
                    end
                end
                
                if raw_ts.getStatusAt(i) == ScnRecording.STATUS_BAD
                     resolved_status(end)=ScnRecording.STATUS_BAD;
                end
       
            %we have one more interval which I don't think we use as we don't
            %know how long it lasts for
                
            end
        
            resolved_points=length(resolved_intervals);
            rts=ScnRecording(resolved_intervals,resolved_ampls,resolved_status,resolved_points);         

        
        end
    end
    
end

