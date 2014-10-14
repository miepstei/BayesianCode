function [buckets,frequency,dx] =  Histogram(intervals,startx)
    num_intervals = length(intervals);
    max_interval = max(intervals);

    if num_intervals < 300
        numBinsPerDecade = 5;
    elseif num_intervals < 1000
        numBinsPerDecade = 8;
    elseif num_intervals < 3000
        numBinsPerDecade = 10;
    else
        numBinsPerDecade = 12;
    end

    end_point = 1+max_interval-rem(max_interval,1);%bucket to the longest second 
    dx = exp(log(10)/numBinsPerDecade);
    nbin = 1 + floor(log(end_point/startx)/log(dx));
    x = zeros(nbin,1);

    %create the scaled axis
    for i=1:nbin
        x(i) = startx * (dx^(i-1));
    end

    y = histc(intervals,x)';
    %kron here interleaves duplicates into the vectors e.g [1 3 4] -> [1 1 3 3 4 4]
    %so that the stairs effect is visable in the semilogx plot

    buckets = kron(x,[1 1]');
    frequency = [ 0; kron(y(1:end-1),[1 1]')] ;
    frequency(end+1) = 0;
end


