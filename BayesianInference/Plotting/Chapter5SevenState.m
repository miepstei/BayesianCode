%% Testing on Seven State models in Chapter 5
clear

% here we are trying to show convergence (or lack of it) from starting
% postion Guess 2

%% load the true param values and the guesses
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));

%posterior mode:
max_param = [2124.4342,54362.4452,5858.5594,52.6450,43851.2042,150.2599,219016490.2130,1552.3899,9367.9090,378991351.7718];
max_post = 8.4475e+04;

%Preconditioned algoirthms converge...
preconditioned_mala = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Replicates_10/Guess2/Experiment29_1032577617.mat');
load(preconditioned_mala)

f=figure('visible','on');
plot(samples.params(:,1));
hold on
line([0,samples.N],[true1(1),true1(1)],'LineStyle','--','Color','r')
line([0,samples.N],[max_param(1),max_param(1)],'LineStyle','--','Color','g')
xlabel('Iteration')
ylabel('Sample of $\alpha_2$','Interpreter','latex')
hold off
Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/PreconMALA_Ten_Param_Convergence']);

%show convergence to the true posterior mode
f=figure('visible','on');
plot(samples.posteriors(SamplerParams.Burnin+1:end,1));
xlabel('Iteration')
ylabel('Model Log-Posterior')
axis = findall(f,'type','axes');
ylimits = get(axis,'ylim');
ylimits(1) = ylimits(1)-1;
ylimits(2) = max_post+1;
set(axis,'ylim',ylimits)
hold on
line([0,samples.N-SamplerParams.Burnin],[max_post,max_post],'LineStyle','--','Color','r')
Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/PreconMALA_Posterior_Convergence']);

clearvars -except guess* true* *param_keys param_names max_param max_post

%now preconditioned random walk

multiplicative_rwmh_component = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Replicates_10/Guess2/Experiment30_833726172.mat');
load(multiplicative_rwmh_component)

f=figure('visible','on');
plot(samples.params(:,1));
hold on
line([0,samples.N],[true1(1),true1(1)],'LineStyle','--','Color','r')
line([0,samples.N],[max_param(1),max_param(1)],'LineStyle','--','Color','g')
xlabel('Iteration')
ylabel('Sample of $\alpha_2$','Interpreter','latex')
hold off
Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/PreconRWMH_Ten_Param_Convergence'],16,16);

%show convergence to the true posterior mode
f=figure('visible','on');
plot(samples.posteriors(SamplerParams.Burnin+1:end,1));
xlabel('Iteration')
ylabel('Model Log-Posterior')
axis = findall(f,'type','axes');
ylimits = get(axis,'ylim');
ylimits(1) = ylimits(1)-1;
ylimits(2) = max_post+1;
set(axis,'ylim',ylimits)
hold on
line([0,samples.N-SamplerParams.Burnin],[max_post,max_post],'LineStyle','--','Color','r')

Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/PreconRWMH_Posterior_Convergence'],16,16);

clearvars -except guess* true* *param_keys param_names max_param max_post
%% now find non conditioned strategies

% multiplicative_rwmh_component = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Replicates_10/Guess2/Experiment8_825912083.mat');
% multiplicative_rwmh_component2 = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Replicates_10/Guess2/Experiment8_825933171.mat');
% load(multiplicative_rwmh_component)
% 
% %show convergence to the true posterior mode
% f=figure('visible','off');
% plot(samples.posteriors(SamplerParams.Burnin+1:end,1));
% xlabel('Iteration')
% ylabel('Model Log-Posterior')
% hold on
% line([0,samples.N-SamplerParams.Burnin],[max_post,max_post],'LineStyle','--','Color','r')
% load(multiplicative_rwmh_component2)
% plot(samples.posteriors(SamplerParams.Burnin+1:end,1),'g');
% 
% Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/MultRWMH_Posterior_Convergence']);
% clearvars -except guess* true* *param_keys param_names max_param max_post

%% adaptive

adaptive_trucated = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment27_663834637.mat');
load(adaptive_trucated)

%show convergence to the true posterior mode
f=figure('visible','on');
plot(samples.params(:,1));
hold on
line([0,samples.N],[true1(1),true1(1)],'LineStyle','--','Color','r')
line([0,samples.N],[max_param(1),max_param(1)],'LineStyle','--','Color','g')
xlabel('Iteration')
ylabel('Sample of $\alpha_2$','Interpreter','latex')
hold off
Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/TruncatedAdaptive_Ten_Param_Convergence'],16,16);

f=figure('visible','on');
plot(samples.posteriors(:,1));
xlabel('Iteration')
ylabel('Model Log-Posterior')
axis = findall(f,'type','axes');
ylimits = get(axis,'ylim');
ylimits(1) = ylimits(1)-1;
ylimits(2) = max_post+1;
set(axis,'ylim',ylimits)
hold on
line([0,samples.N],[max_post,max_post],'LineStyle','--','Color','r')

Plot1By1(f,0,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/TruncatedAdaptive_Posterior_Convergence'],16,16);


delete(findall(0,'Type','figure'))