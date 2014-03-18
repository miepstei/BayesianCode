%% Plots for MCMC chapter of upgrade report
%These variables shoule never be cleared

P_HOME=getenv('P_HOME');

%these are the "true1" rate constants used to generate data
true1_parameters=[2000 52000 6000 50 50000 150 1500 2e8 10000 4e8 1500 2e8 10000 4e8];
parameter_keys=[1,2,3,4,5,6,11,13,14];

%%Burinin plots for Single MCMC chain, 9 parameter model
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
load([P_HOME '/Results/MCMC/single_run.mat_BurnIn_1-50000.mat'])

f=figure();
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plot(10.^Samples_BurnIn{end,1}.Paras(:,ind))
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_burnin']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_burnin.tikz' ]);
close(f);

clearvars -except P_HOME true1_parameters param_names parameter_keys

%%Posterior plots for Single MCMC chain, 9 parameter model
load([P_HOME '/Results/MCMC/single_run.mat_Posterior_1-50000.mat'])

% Mixing plots
f=figure();

for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plot(10.^Samples_Posterior{end,1}.Paras(:,ind))
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior.tikz' ]);
close(f);

% parameter correlations from posterior
f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:9;
    for j=1:9;
        ind =(j)+(9*(i-1));
        if (i > j) %n(n-1)/2
            subplot(9,9,ind);
            scatter(10.^Samples_Posterior{end,1}.Paras(:,i),(10.^Samples_Posterior{end,1}.Paras(:,j)))
            title([param_names{i} ' - ' param_names{j}] ,'interpreter','latex');
            set(gca,'xtick',[],'ytick',[])
        end
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_correlations']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_correlations.tikz' ]);
close(f);


%selected pairwise correlations made to illustrate a point
f=figure();
subplot(3,1,1);
scatter(10.^Samples_Posterior{end,1}.Paras(:,1),(10.^Samples_Posterior{end,1}.Paras(:,2)),'.')
title([param_names{1} ' - ' param_names{2}] ,'interpreter','latex');
 subplot(3,1,2);
scatter(10.^Samples_Posterior{end,1}.Paras(:,4),(10.^Samples_Posterior{end,1}.Paras(:,7)),'.')
title([param_names{4} ' - ' param_names{7}] ,'interpreter','latex');
subplot(3,1,3);
scatter(10.^Samples_Posterior{end,1}.Paras(:,6),(10.^Samples_Posterior{end,1}.Paras(:,8)),'.')
title([param_names{6} ' - ' param_names{8}] ,'interpreter','latex');


print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9_selected_pairwise_correlation']);
close(f);

% parameter distributions
f=figure();

for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(10.^Samples_Posterior{end,1}.Paras(:,ind))
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_dist']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_dist.tikz' ]);
close(f);

%ACF

f=figure();
numLags=100;
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        autocorr(10.^Samples_Posterior{end,1}.Paras(:,ind),numLags)
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_acf']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_acf.tikz' ]);
close(f);

%calculate effective sample sizes
eff=zeros(9,1);

%sample autocorrelations start at lag 0
numLags=750; %parameter 1 loses significant lags at this point

for i=1:9
    [acf,~,~] = autocorr(10.^Samples_Posterior{end,1}.Paras(:,i),numLags);
    eff(i)=length(Samples_Posterior{end,1}.Paras(:,i))/(1+2*(sum(acf(2:end))));
end

%Posterior parameter distributions
g=figure();
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        [f,x]=hist(10.^Samples_Posterior{end,1}.Paras(:,ind),25);
        bar(x,f/trapz(x,f));
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end
end

print(g,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_hists']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_9params_posterior_hists.tikz' ]);

clearvars -except P_HOME true1_parameters param_names parameter_keys

%%Parallel temporing

%This is some debugging. We want to check that we can sample from both
%modes from a single concentration

load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])

%find the empirical modes by MLE fitting
mode1=fitted_params(:,1)<2500;
mode2=(fitted_params(:,1)>10000 & fitted_params(:,1)<30000);

load([P_HOME '/Results/MCMC/find_mode_1.mat_Posterior_1-5000.mat'])
f=figure();
%Plot of the first mode
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(10.^Samples_Posterior{1,1}.Paras(:,ind)); hold on;
        plot(mean(fitted_params(mode1,ind)),0,'rp');
        hold off;
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_first_mode_9params_posterior_hists']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_first_mode_9params_posterior_hists.tikz' ]);
close(f);


clearvars -except P_HOME true1_parameters param_names mode1 mode2 fitted_params parameter_keys

%Plot of the second mode

load([P_HOME '/Results/MCMC/find_mode_2.mat_Posterior_1-5000.mat'])
f=figure();
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(10.^Samples_Posterior{1,1}.Paras(:,ind)); hold on;
        plot(mean(fitted_params(mode2,ind)),0,'rp');
        hold off;
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_single_chain_second_mode_9params_posterior_hists']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_single_chain_second_mode_9params_posterior_hists.tikz' ]);

clearvars -except P_HOME true1_parameters param_names mode1 mode2 fitted_params parameter_keys

%%Posterior plots for 30 MCMC chain, 9 parameter model
load([P_HOME '/Results/MCMC/find_modes_log_30_temps_100000_samples_short_priors.mat_Posterior_1-100000.mat'])
f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(10.^Samples_Posterior{end,1}.Paras(:,ind)); hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_hists']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_hists.tikz' ]);


% Mixing plots we take the first 50,000 posterior samples to show how it
% contrasts with the single chain
f=figure();
set(f, 'Position',[0 0 1000 1000])

for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plot(10.^Samples_Posterior{end,1}.Paras(1:50000,ind))
        title(param_names{ind},'interpreter','latex');
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_mixing']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_mixing.tikz' ]);


%ACF - first 50,000 posterior samples

f=figure();
numLags=100;
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        autocorr(10.^Samples_Posterior{end,1}.Paras(1:50000,ind),numLags)
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_acf']);
matlab2tikz( [P_HOME '/../../Written/thesis_1/Figures/MCMC_30_chain_9params_posterior_acf.tikz' ] );
close(f);


%calculate effective sample sizes
eff=zeros(9,1);

%sample autocorrelations start at lag 0
numLags=750; %parameter 1 loses significant lags at this point

for i=1:9
    [acf,~,~] = autocorr(10.^Samples_Posterior{end,1}.Paras(:,i),numLags);
    eff(i)=length(Samples_Posterior{end,1}.Paras(:,i))/(1+2*(sum(acf(2:end))));
end


%we want to show how the distributions evolve from the prior to the
%posterior for parameter 1
f=figure();
for i=1:6
    subplot(6,1,i);
    hold on;
    title(sprintf('Posterior chain %i',i*5))
    hist(10.^Samples_Posterior{i*5,1}.Paras(10.^Samples_Posterior{i*5,1}.Paras(1:50000,1)<20000,1))
    plot(mean(fitted_params(mode1,1)),0,'rp');
    plot(mean(fitted_params(mode2,1)),0,'bp');
    xlim([0 20000])
    hold off;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/MCMC_30_chain_9params_prior_posterior_acf']);
close(f)
clearvars -except P_HOME true1_parameters parameter_keys
