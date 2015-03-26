clear

%% load the true param values and the guesses
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));

%% RWMH componentwise
component_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment9_713641785.mat');
load(component_adjustment)

%%Determine the mode for this dataset
%fprintf('Determining mode...\n')
%options = optimset('fminsearch');
%options.MaxIter=100000;
%options.MaxFunEvals=100000;
%startParams=true1(ten_param_keys);
%[x,fval,exitflag] = fminsearch(@(params)-model.calcLogPosterior(params,data),startParams,options);
%fprintf('Max likelihood is %.4f, params %.4f %.4f\n',fval,x(1),x(2))
max_param=2104.73,53924.89,5845.00,53.02,44548.42,151.00,219180796.79,1569.21,9370.46,380010297.22;
max_post = 84471.5684;

%show convergence to the $\alpha_2$ component

f=figure('visible','off');
plot(samples.params(:,1));
hold on
line([0,samples.N],[true1(1),true1(1)],'LineStyle','--','Color','r')
line([0,samples.N],[max_param(1),max_param(1)],'LineStyle','--','Color','g')
xlabel('Iteration')
ylabel('Sample of $\alpha_2$','Interpreter','latex')
hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Ten_Param_Convergence']);

%show convergence to the true posterior mode
f=figure('visible','off');
plot(samples.posteriors(:,1));
xlabel('Iteration')
ylabel('Model Log-Posterior')
hold on
line([0,samples.N],[max_post,max_post],'LineStyle','--','Color','r')

posSmall{1} = [0.5 0.6 0.3 0.24];

%# create axes (small)
hAxS(1) = axes('Position',posSmall{1});

%# plot
plot(hAxS(1), SamplerParams.Burnin:samples.N,samples.posteriors(SamplerParams.Burnin:end,1), 'b');
line([0,samples.N],[max_post,max_post],'LineStyle','--','Color','r')

%# set axes properties
set(hAxS , 'Color','none', 'XAxisLocation','top', 'YAxisLocation','right');

hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Ten_Param_Convergence_To_Posterior']);

%show autocorrelation of \alpha_2 and \beta_2
f=figure('Visible','off');
param = {'$\alpha_2$','$\beta_2$'};
for i=1:2
    subplot(1,2,i)
    autocorr(samples.params(SamplerParams.Burnin:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param{i},'interpreter','latex')
end

Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Ten_Param_Autocorrelations']);

%Gaussian fit to scatter plot of \alpha_2 and \beta_2
MoGOptions = statset('Display', 'final');
MoGObj1 = gmdistribution.fit([samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2)], 1, 'Options', MoGOptions);
f=figure('Visible','off');
scatter(samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2), 5, '.')
hold on
ezcontour(@(x,y)pdf(MoGObj1,[x y]), [1800 2400, 4.8*(10^4) 6*(10^4)],1000);
title('')
xlabel(param{1})
ylabel(param{2})
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Ten_Param_Pairwise']);

%ratio of accepted to unaccepted samples along the direction of
%correlation, \alpha_2
f=figure('Visible','off');
z = samples.proposals(SamplerParams.Burnin:end,:);
scatter(z(~logical(samples.acceptances(SamplerParams.Burnin:end,2)),1),z(~logical(samples.acceptances(SamplerParams.Burnin:end,2)),2),50, '.')
hold on
scatter(z(logical(samples.acceptances(SamplerParams.Burnin:end,2)),1),z(logical(samples.acceptances(SamplerParams.Burnin:end,2)),2),50, '.')
title('')
%xlim([1500 2500])
%ylim([4.8*(10^4) 6*(10^4)])
xlabel(param{1})
ylabel(param{2})
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Component_Adjust_Ten_Param_Proposals']);

%% multiplicative adjustments
clearvars -except guess* true* *param_keys param_names max_param max_post

multiplicative_adjustment = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment8_713642929.mat');
load(multiplicative_adjustment)

f=figure('visible','off');
plot(samples.params(:,1));
hold on
line([0,samples.N],[true1(1),true1(1)],'LineStyle','--','Color','r')
line([0,samples.N],[max_param(1),max_param(1)],'LineStyle','--','Color','g')
xlabel('Iteration')
ylabel('Sample of $\alpha_2$','Interpreter','latex')
hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Ten_Param_Convergence']);

%show convergence to the true posterior mode
f=figure('visible','off');
plot(samples.posteriors(:,1));
xlabel('Iteration')
ylabel('Model Log-Posterior')
hold on
line([0,samples.N],[max_post,max_post],'LineStyle','--','Color','r')

posSmall{1} = [0.5 0.6 0.3 0.24];

%# create axes (small)
hAxS(1) = axes('Position',posSmall{1});

%# plot
plot(hAxS(1), SamplerParams.Burnin:samples.N,samples.posteriors(SamplerParams.Burnin:end,1), 'b');
line([0,samples.N],[max_post,max_post],'LineStyle','--','Color','r')

%# set axes properties
set(hAxS , 'Color','none', 'XAxisLocation','top', 'YAxisLocation','right');

hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Ten_Param_Convergence_To_Posterior']);

%show autocorrelation of \alpha_2 and \beta_2
f=figure('Visible','off');
param = {'Alpha_2','Beta_2'};
for i=1:2
    subplot(1,2,i)
    autocorr(samples.params(SamplerParams.Burnin:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param{i},'interpreter','latex')
end

Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Ten_Param_Autocorrelations']);

%Gaussian fit to scatter plot of \alpha_2 and \beta_2
MoGOptions = statset('Display', 'final');
MoGObj1 = gmdistribution.fit([samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2)], 1, 'Options', MoGOptions);
f=figure('Visible','off');
scatter(samples.params(SamplerParams.Burnin:end,1),samples.params(SamplerParams.Burnin:end,2), 5, '.')
hold on
ezcontour(@(x,y)pdf(MoGObj1,[x y]), [1800 2400, 4.8*(10^4) 6*(10^4)],1000);
title('')
xlabel(param{1})
ylabel(param{2})
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Ten_Param_Pairwise']);

%ratio of accepted to unaccepted samples along the direction of
%correlation, \alpha_2
f=figure('Visible','off');
z = samples.proposals(SamplerParams.Burnin:end,:);
scatter(z(~logical(samples.acceptances(SamplerParams.Burnin:end,2)),1),z(~logical(samples.acceptances(SamplerParams.Burnin:end,2)),2),50, '.')
hold on
scatter(z(logical(samples.acceptances(SamplerParams.Burnin:end,2)),1),z(logical(samples.acceptances(SamplerParams.Burnin:end,2)),2),50, '.')
title('')
%xlim([1500 2500])
%ylim([4.8*(10^4) 6*(10^4)])
xlabel(param{1})
ylabel(param{2})
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/RWMH_Mult_Component_Adjust_Ten_Param_Proposals']);

delete(findall(0,'Type','figure'))


