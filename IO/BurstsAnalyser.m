classdef BurstsAnalyser
    %BURSTSANALYSER Performs analytics on cell arrays of bursts
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function lengths=getBurstLengths(bursts)
            %returns array of the time within each burst
            lengths=[bursts.burst_length];
        end
        
        function openings=fetchNumberOfBurstOpenings(bursts)
            %returns array of the number of openings within each burst
            openings=[bursts.no_of_openings];
        end
        
        
    end
    
end

