function [ out_bursts ] = transpose_bursts( in_bursts )
    %transpose_bursts transposes the burst structure from scipy.savemat
    %which saves vectors as column vectors
    burst_data_size = size(in_bursts);
    out_bursts = cell(sort(burst_data_size));
    
    for burst_group = 1:burst_data_size(1)
        out_bursts{burst_group}=in_bursts{burst_group}';
        for bursts=1:length(in_bursts{burst_group})
            out_bursts{1,burst_group}{1,bursts} = in_bursts{burst_group,1}{bursts,1}';
        end
    end
end

