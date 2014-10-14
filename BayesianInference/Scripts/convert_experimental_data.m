function convert_experimental_data(dcpyps_experimental_datafile,filename)
    %Converts and saves an experimental data file into BayesianCode format
    %to get around limitations of scipy.io 
    load(dcpyps_experimental_datafile);
    bursts = transpose_bursts(bursts);
    
    %need to standardise the openings in the recording interval
    resolved_data = cell(length(concs),1);
    for i=1:length(concs)
        idx = abs(resolved_amplitudes{i}) > eps('double');
        resolved_amplitudes{i,1}(idx) = 1;
        resolved_data{i} = ScnRecording(resolved_intervals{i}',resolved_amplitudes{i}',resolved_flags{i}',length(resolved_intervals{i}));
    end
    
    save(filename,'resolved_data','bursts','concs','tcrit','tres','useChs')
end

