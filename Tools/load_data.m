function [burst_array,description]=load_data(files,tres,tcrit)
    %This function takes a list of file names and returns a list of bursts
    %for fitting
    
    %INPUTS:    files - a cell array of n file paths to .scn files
    %           tres - an array of tres times to apply
    %           tcrit - an array of tcrit times to apply
                
    %OUTPUTS: an n cell array containing bursts
    
    
    number_of_files = length(files);
    burst_array=cell(number_of_files,1);
    description=struct();

    description.file_number = number_of_files;
    description.file_names = files;
    
    for i=1:length(files)
        [~,data]=DataController.read_scn_file(files{i});
        data.intervals=data.intervals/1000;
        resolvedData = RecordingManipulator.imposeResolution(data,tres(i));
        bursts = RecordingManipulator.getBursts(resolvedData,tcrit(i));
        stripped_bursts = [bursts.withinburst];
        burst_array{i} = {stripped_bursts.intervals};
        
        description.dataset(i).interval_no = length(data.intervals); 
        description.dataset(i).burst_no = length(bursts);
        description.dataset(i).average_openings_per_burst = sum(BurstsAnalyser.fetchNumberOfBurstOpenings(bursts))/description.dataset(i).burst_no;
        description.dataset(i).average_burst_length = sum(BurstsAnalyser.getBurstLengths(bursts))/description.dataset(i).burst_no;

    end
end