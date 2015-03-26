%likelihood surface
lik_surface = strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEventsZoom.mat');
load(lik_surface)

%no adjustment RWMH
no_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_no_adjustment498624931.mat');
load(no_adjustment)

f=figure('Visible','off');
sample_no=1:samples.N;
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')

Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Two_Param_Trace'])
%print(f,'-depsc',[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Two_Param']);

clearvars -except param_1 param_2 surface_zoom TRUE_PARAM_1 TRUE_PARAM_2 sample_no

%% adjustment RWMH
adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_adjustment498932558.mat');
load(adjustment)

f=figure('Visible','off');
sample_no=1:samples.N;
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')

Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Adjust_Two_Param_Trace'])

clearvars -except param_1 param_2 surface_zoom TRUE_PARAM_1 TRUE_PARAM_2 sample_no


%% component_adjustment RWMH
component_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/TwoState/rwmh_adjustment_cw506560092.mat');
load(component_adjustment)


f=figure('Visible','off');
contour((param_1),(param_2),surface_zoom,50)
hold on
plot(samples.params(1:10000,1),samples.params(1:10000,2))
xlabel('$\alpha$','interpreter','latex')
ylabel('$\beta$','interpreter','latex')
line([1000,1000],[min(param_2),max(param_2)],'LineStyle','--','Color','r')
line([min(param_1),max(param_1)],[10^7,10^7],'LineStyle','--','Color','r')
hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_LogSurface']);

f=figure('Visible','off');
sample_no=1:samples.N;
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')

Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Trace']);


%Autocorrelations of this sample
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};
for i=1:2
    subplot(1,2,i)
    autocorr(samples.params(SamplerParams.Burnin:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param{i})
end
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Autocorrelations']);
clear f;

%posterior histograms and scatter
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};
for i=1:2
    subplot(1,3,i)
    hist(samples.params(SamplerParams.Burnin:end,i),100)
    xlabel('Lag')
    ylabel(param{i})
end
subplot(1,3,3)
%scatter(samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2),1)
xlabel(param{1})
ylabel(param{2})

%print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Pairwise']);
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Two_Param_Pairwise']);


Y = quantile(samples.params(SamplerParams.Burnin+1:end,1),[0.025 0.975]);
Y = quantile(samples.params(SamplerParams.Burnin+1:end,2),[0.025 0.975]);
clear f;
clearvars -except param_1 param_2 surface_zoom TRUE_PARAM_1 TRUE_PARAM_2 sample_no

%% multiplicative component-adjusted RWMH
multiplicative_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/ExperimentA_669752074.mat');
load(multiplicative_adjustment)
f=figure('Visible','off');


contour((param_1),(param_2),surface_zoom,50)
hold on
plot(samples.params(1:1000,1),samples.params(1:1000,2))
xlabel('$\alpha$','interpreter','latex')
ylabel('$\beta$','interpreter','latex')
line([1000,1000],[min(param_2),max(param_2)],'LineStyle','--','Color','r')
line([min(param_1),max(param_1)],[10^7,10^7],'LineStyle','--','Color','r')
hold off

Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Two_Param_LogSurface']);

f=figure('Visible','off');
sample_no=1:samples.N;
plotyy(sample_no,samples.params(:,1),sample_no,samples.params(:,2))
xlabel('Iteration')
ylabel('Param Value')

Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Two_Param_Trace']);

%Autocorrelations of this sample
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};
for i=1:2
    subplot(1,2,i)
    autocorr(samples.params(SamplerParams.Burnin:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param{i},'interpreter','latex')
end

Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Two_Param_Autocorrelations']);

clear f;

%posterior histograms and jet(64)
quantiles(1,:) = quantile(samples.params(SamplerParams.Burnin+1:end,1),[0.025 0.975]);
quantiles(2,:) = quantile(samples.params(SamplerParams.Burnin+1:end,2),[0.025 0.975]);
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};
for i=1:2
    subplot(1,2,i)
    hold on;
    hist(samples.params(SamplerParams.Burnin:end,i),20);
    c =ylim;
    line([quantiles(i,1),quantiles(i,1)],[0,c(2)],'LineStyle','--','Color','r')
    line([quantiles(i,2),quantiles(i,2)],[0,c(2)],'LineStyle','--','Color','r')
    hold off
    xlabel(param{i},'interpreter','latex')
    ylabel('Samples')
end

Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Two_Param_Marginal']);

%Gaussian fit to scatter plots
MoGOptions = statset('Display', 'final');
MoGObj1 = gmdistribution.fit([samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2)], 1, 'Options', MoGOptions);
f=figure('Visible','on');
scatter(samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2), 5, '.')
hold on
ezcontour(@(x,y)pdf(MoGObj1,[x y]), [950 1050, 9.9^7 10.1^7],1000);
title('')
xlabel(param{1},'interpreter','latex')
ylabel(param{2},'interpreter','latex')
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Two_Param_Pairwise']);

close all;

clear;



