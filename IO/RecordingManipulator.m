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
            
            %the intervals of shut times > t_crit. The first resolved
            %interval is an open time so we add the 0th index as a long
            %shut time in order to capture this opening in a burst.
            long_closed_intervals=[0 getShutIntervalGreaterThan(res_ts,t_crit)];

            %we want to create the bursts which are defined between the
            %intervals of the long shut times
            
            for long_closed_interval=1:length(long_closed_intervals)-1
                %the burst indices are non-inclusively between the nth long shut period and
                %the n+1th long shut period. Ie. if n=3, n+1=7, we want
                %4,5,6 representing the indices in the burst.
                
                %we want the loop to continue until long_closed_interval =
                %n-1 as we use the nth interval as the forward marker.
                
                burst_interval=long_closed_intervals(long_closed_interval)+1:long_closed_intervals(long_closed_interval+1)-1;
                          
                wb_amps = res_ts.getAmps(burst_interval(1),burst_interval(end));
                wb_intervals = res_ts.getInts(burst_interval(1),burst_interval(end));
                wb_status=res_ts.getStatuses(burst_interval(1),burst_interval(end));
                wb=struct('amps',wb_amps,'intervals',wb_intervals,'status',wb_status);
                
                openings=sum(wb_amps>0);
                indiv_open_length=wb_intervals(wb_amps>0);
                burst_length=sum(wb_intervals);
                open_burst=sum(wb_intervals(wb_amps>0));
                open_amps=wb_amps(wb_amps>0);
                mean_amp=sum(indiv_open_length.*open_amps)/openings;
                burst_status=sum(wb_status==ScnRecording.STATUS_BAD);
                burst=Burst(wb,openings,open_burst,burst_length,burst_status,indiv_open_length,mean_amp);
               
                %now add the burst
                burst_array(long_closed_interval)=burst;
                
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
            
            %we need to find the first resolvable period
            while ~found_period
                if (raw_ts.getIntervalAt(index) > res) && (raw_ts.getStatusAt(index) ~= ScnRecording.STATUS_BAD) && raw_ts.getAmpAt(index) < RecordingManipulator.EPSILON
                    found_period=true;  
                end
                index=index+1;
            end
            %the actual first resolved interval in the resolved record is
            %the second unresolved (n+1) interval which is open; the n-1 interval is unresoved
            %which means we don't actually know how long the nth closed resolved
            %period actually is.
           
            
            
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
            
            if resolved_ampls(end) > 0
                %we don't know how long the last open interval will last so
                %we don't want to include it in the resolved record. If it
                %is closed we don't care
                resolved_ampls=resolved_ampls(1:end-1);
                resolved_status=resolved_status(1:end-1);
                resolved_intervals=resolved_intervals(1:end-1);
                
            end
        
            resolved_points=length(resolved_intervals);
            rts=ScnRecording(resolved_intervals,resolved_ampls,resolved_status,resolved_points);         

        
        end
    end
    
end

