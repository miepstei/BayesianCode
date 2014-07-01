function AnalyseResults(samples,length,width,burnin_percent,varargin)

param_count=size(samples.params,2);
sample_count=size(samples.params,1);

burnin=ceil(sample_count*burnin_percent);

nVarargs = max(size(varargin));
if nVarargs == 2
    trueParams = varargin{1};
    paramNames = varargin{2};
end

figure;
for i=1:param_count
    subplot(length,width,i)
    plot(samples.params(burnin:end,i))
end

figure;
for i=1:param_count
    subplot(length,width,i)
    autocorr(samples.params(burnin:end,i),100)
end

figure;
for i=1:param_count
    subplot(length,width,i)
    [f,x]=hist(samples.params(burnin:end,i),100);
    bar(x,f/trapz(x,f));
    hold on;
    if nVarargs == 2
        plot(trueParams(i),0,'rp');
        hold off;    
        title(paramNames{i},'interpreter','latex');
    end
end

figure;
plotmatrix(samples.params(burnin:end,:));

%deal with cw samples
[~, W] = size(samples.acceptances);

if W > 1
    fprintf('Acceptance Ratio after burnin %.2f\n',sum(sum(samples.acceptances(burnin:end,:)))/((sample_count-burnin)*W))
else
    fprintf('Acceptance Ratio after burnin %.2f\n',sum(samples.acceptances(burnin:end))/(sample_count-burnin) )
end

end
