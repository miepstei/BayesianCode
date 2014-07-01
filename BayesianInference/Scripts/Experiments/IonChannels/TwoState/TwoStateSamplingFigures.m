%likelihood surface
lik_surface = strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEvents.mat');
load(lik_surface)

%no adjustment RWMH
no_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_no_adjustment498624931.mat');
load(no_adjustment)

f=figure('Position',[100   637   687   349]);


subplot(1,2,1)
contour(param_1,param_2,surface,20); hold on
cmp = jet(samples.N); 
scatter(log(samples.params(:,1)/TRUE_PARAM_1),log(samples.params(:,2)/TRUE_PARAM_2),10, cmp, 'filled')
xlabel('Param 1 - Alpha')
ylabel('Param 2 - Beta')
title('Likelihood Surface')
hold off

subplot(1,2,2)
sample_no=1:samples.N;
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')
title('Trace Plots')

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf RWMH','HorizontalAlignment' ,'center','VerticalAlignment', 'top')
print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Two_Param']);
clearvars -except param_1 param_2 surface TRUE_PARAM_1 TRUE_PARAM_2 sample_no

%adjustment RWMH
adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_adjustment498932558.mat');
load(adjustment)

f=figure('Position',[100   637   687   349]);
subplot(1,2,1)
contour(param_1,param_2,surface,20); hold on
cmp = jet(samples.N); 
scatter(log(samples.params(:,1)/TRUE_PARAM_1),log(samples.params(:,2)/TRUE_PARAM_2),10, cmp, 'filled')
xlabel('Param 1 - Alpha')
ylabel('Param 2 - Beta')
title('Likelihood Surface')

hold off

subplot(1,2,2)
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')
title('Trace Plots')


ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Adjusted RWMH','HorizontalAlignment' ,'center','VerticalAlignment', 'top')
print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Adjust_Two_Param']);

clearvars -except param_1 param_2 surface TRUE_PARAM_1 TRUE_PARAM_2 sample_no


%component_adjustment RWMH
component_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_adjustment_cw506560092.mat');
load(component_adjustment)

f=figure('Position',[100   637   687   349]);


subplot(1,2,1)
contour(param_1,param_2,surface,20); hold on
cmp = jet(samples.N); 
scatter(log(samples.params(:,1)/TRUE_PARAM_1),log(samples.params(:,2)/TRUE_PARAM_2),10, cmp, 'filled')
xlabel('Param 1 - Alpha')
ylabel('Param 2 - Beta')
title('Likelihood Surface')
hold off

subplot(1,2,2)
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')
title('Trace Plots')

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Component-scaled RWMH','HorizontalAlignment' ,'center','VerticalAlignment', 'top')
print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param']);


%%
%Autocorrelations of this sample
f=figure('Position',[100   637   687   349]);
param = {'Alpha','Beta'};
for i=1:2
    subplot(1,2,i)
    autocorr(samples.params(SamplerParams.Burnin:end,i),100)
    xlabel('Lag')
    ylabel(param{i})
end
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf Component-scaled RWMH Autocorrelations','HorizontalAlignment' ,'center','VerticalAlignment', 'top')
print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Autocorrelations']);
clear f;

%posterior histograms and scatter
f=figure('Position',[100   637   687   349]);
param = {'Alpha','Beta'};
for i=1:2
    subplot(1,3,i)
    hist(samples.params(SamplerParams.Burnin:end,i),100)
    xlabel('Lag')
    ylabel(param{i})
end
subplot(1,3,3)
scatter(samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2),1)
xlabel(param{1})
ylabel(param{2})
title(['Pairwise scatter of ' param{1} ' and ' param{2}] )
print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Pairwise']);
Y = quantile(samples.params(SamplerParams.Burnin+1:end,1),[0.025 0.975])
Y = quantile(samples.params(SamplerParams.Burnin+1:end,2),[0.025 0.975])
clear f;
%clearvars -except param_1 param_2 surface TRUE_PARAM_1 TRUE_PARAM_2 sample_no



