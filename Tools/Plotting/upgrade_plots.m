%% Plots for upgrade report

%These variables shoule never be cleared

P_HOME=getenv('P_HOME');

%these are the "true1" rate constants used to generate data
true1_parameters=[2000 52000 6000 50 50000 150 1500 2e8 10000 4e8 1500 2e8 10000 4e8];


%% 9 model parameter experiments
parameter_keys=[1,2,3,4,5,6,11,13,14];
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 5000],[0 15000],[0 6e8]};

%EXPERIMENT 0a - 1000 fits to a single file using Random as the
%starting point

load([P_HOME '/Results/dcprogs/Exp0a_14102013.mat'])

f = figure();
set(f, 'Position',[0 0 1000 1000])

subplot(2,2,1);
hist(fitted_params(:,1),400);
title('Distribution of $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
ylabel('Count'); 

subplot(2,2,2);
scatter(log(fitted_params(:,1)),-fitted_likelihoods);
title('Scatter of log($\beta_2$) versus Likelihood','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
ylabel('-Max Likelihood'); 


subplot(2,2,3);
hist(fitted_params(:,2),400);
title('Distribution of $\beta_2$','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
ylabel('Count'); 

subplot(2,2,4);
scatter(fitted_params(:,1),fitted_params(:,2));
title('Scatter of $\beta_2$ versus $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
ylabel('$\beta_2$','interpreter','latex'); 

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0a']);
close(f);

f = figure();
set(f, 'Position',[0 0 1000 1000])


for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(param_names{ind},'interpreter','latex');
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0a_allparams']);
close(f);

clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%EXPERIMENT 0b - Profile likelihoods generated from random starting
%positions on one dataset

%EXPERIMENT 0c - 1000 fits to a 1000 files using Random as the
%starting point

load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])

f = figure();
set(f, 'Position',[0 0 1000 1000])

subplot(2,2,1);
hist(fitted_params(:,1),400);
title('Distribution of $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
xlim([0 3e4])
l=ylim;
line([true1_parameters(1),true1_parameters(1)],ylim,'LineStyle','--','Color','r')
text(2300,l(2)-200,['true \alpha_2 = ' num2str(true1_parameters(1))])
ylabel('Count'); 

subplot(2,2,2);
scatter(log(fitted_params(:,2)),-fitted_likelihoods);
title('Scatter of log($\beta_2$) versus Likelihood','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
l=ylim;
line([log(true1_parameters(2)),log(true1_parameters(2))],ylim,'LineStyle','--','Color','r')
ylabel('-Max Likelihood'); 


subplot(2,2,3);
hist(fitted_params(:,2),400);
title('Distribution of $\beta_2$','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
line([true1_parameters(2),true1_parameters(2)],ylim,'LineStyle','--','Color','r')
text(100000,20,['true \beta_2 = ' num2str(true1_parameters(2))])
ylabel('Count'); 

subplot(2,2,4);
scatter(fitted_params(:,1),fitted_params(:,2));
title('Scatter of $\beta_2$ versus $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
line([true1_parameters(1),true1_parameters(1)],ylim,'LineStyle','--','Color','r')
line(xlim,[true1_parameters(2),true1_parameters(2)],'LineStyle','--','Color','r')
ylabel('$\beta_2$','interpreter','latex'); 


print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0c']);
close(f);

%plot all of the parameters
f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(param_names{ind},'interpreter','latex');
        xlim(xlims{ind})
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0c_allparams']);
close(f);
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%EXPERIMENT 0d - 1000 fits to 1000 files using guess 1

load([P_HOME '/Results/dcprogs/Exp0d_14102013.mat'])

f = figure();
set(f, 'Position',[0 0 1000 1000])
parameter_keys=[1,2,3,4,5,6,11,13,14];
subplot(2,2,1);
hist(fitted_params(:,1),400);
title('Distribution of $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
l=ylim;
line([true1_parameters(1),true1_parameters(1)],ylim,'LineStyle','--','Color','r')
text(2050,l(2)-5,['true \alpha_2 = ' num2str(true1_parameters(1))])
ylabel('Count'); 

subplot(2,2,2);
scatter(log(fitted_params(:,2)),-fitted_likelihoods);
title('Scatter of log($\beta_2$) versus Likelihood','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
l=ylim;
line([log(true1_parameters(2)),log(true1_parameters(2))],ylim,'LineStyle','--','Color','r')
ylabel('-Max Likelihood'); 


subplot(2,2,3);
hist(fitted_params(:,2),400);
title('Distribution of $\beta_2$','interpreter','latex');
xlabel('$\beta_2$','interpreter','latex');
line([true1_parameters(2),true1_parameters(2)],ylim,'LineStyle','--','Color','r')
text(100000,20,['true \beta_2 = ' num2str(true1_parameters(2))])
ylabel('Count'); 

subplot(2,2,4);
scatter(fitted_params(:,1),fitted_params(:,2));
title('Scatter of $\beta_2$ versus $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
line([true1_parameters(1),true1_parameters(1)],ylim,'LineStyle','--','Color','r')
line(xlim,[true1_parameters(2),true1_parameters(2)],'LineStyle','--','Color','r')
ylabel('$\beta_2$','interpreter','latex'); 


print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0d']);
close(f);
%plot all of the parameters

f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(fitted_params(:,ind),40);
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0d_allparams']);
close(f);
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%EXPERIMENT 0e - Profile likelihoods to one data file using guess 1

f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        load([P_HOME '/Results/dcprogs/Exp0v from guess 1/parameter_key_' num2str(parameter_keys(ind)) '.mat'])
        
        subplot(3,3,ind);
        plot(profiles(1,:),profile_likelihoods); %x axis in log space
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0v_allparams']);
close(f);
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%EXPERIMENT 0e - Profile likelihoods to one data file using mode 1

load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])
%we takes the hessian of dataset 1
cov_matrix = reshape(fitted_hessians(1,:,:),size(fitted_hessians,2),size(fitted_hessians,3))^-1;

means=fitted_params(1,:);
max_likelihood=fitted_likelihoods(1);

transform_cov_matrix=diag(1./means)*cov_matrix*diag(1./means);
stdevs = sqrt(diag(transform_cov_matrix));

%for likelihood based intervals
chi1 = chi2inv(0.95,1);

f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        load([P_HOME '/Results/dcprogs/Exp0v/parameter_key_' num2str(parameter_keys(ind)) '.mat'])
        
        subplot(3,3,ind);
        plot(profiles(1,:),profile_likelihoods); %x axis in log space
        hold on;
        
        %add normal approxomation
        ix = -2*stdevs(ind)+log(means(ind)):1e-3:2*stdevs(ind)+log(means(ind)); %covers more than 95% of the curve
        iy = pdf('normal', ix,  log(means(ind)), stdevs(ind));
        plot(ix,max_likelihood-(log(iy)-max(log(iy))),'r');
        line([ix(1) ix(1)],[min(profile_likelihoods) max(profile_likelihoods)],'LineStyle','-');
        line([ix(end) ix(end)],[min(profile_likelihoods) max(profile_likelihoods)],'LineStyle','-');
        
        
        %range for the likelihood based approxomation
        range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
        line([min(profiles(1,range)) min(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([max(profiles(1,range)) max(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp0v_mode1_allparams_intervals']);
close(f);
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;


%%PROFILING THE TWO MODES

%step 1 - determine the two modes
load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])
mode1=fitted_params(:,1)<2500;
mode2=(fitted_params(:,1)>10000 & fitted_params(:,1)<30000);

%means for the rate parameters of mode 1
fprintf('%.16f\n',mean(fitted_params(mode1,:)))

%means for the rate parameters of mode 2
fprintf('%.16f\n',mean(fitted_params(mode2,:)))

f=figure();
set(f, 'Position',[0 0 1000 333])
modal_params=[1 2 8];
for i=1:3;
    subplot(1,3,i);
    [n1,xout1]=hist(fitted_params(mode1,modal_params(i)),20);  
    b1=bar(xout1,n1,'r');
    set(b1,'edgecolor','none')
       
    [n2,xout2]=hist(fitted_params(mode2,modal_params(i)),20);
    hold on;b2=bar(xout2,n2,'b');
    set(b2,'edgecolor','none')
        
    title(param_names{modal_params(i)},'interpreter','latex');
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp1a_modes']);
close(f);
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%{
experiments={'1ai','1aii'};
colours = {'r','b'};
leg={'slow','fast'};
results_dir={'/Volumes/Users/abc/bayesiancode/Results/dcprogs/Exp1ai','/Volumes/Users/abc/bayesiancode/Results/dcprogs/Exp1aii'};
parameter_keys=[1,2,3,4,5,6,11,13,14];
title='Profiling the two modes';
width=3;
height=3;
plot_profiles(results_dir,colours,leg,title,width,height,length(parameter_keys),parameter_keys)

%}

%% plots to vary experimental conditions  
%%VARYING DATA 
width=3;
height=3;
colours = {'r','b','g','y','c','m'};
leg={'500','1000','10000','20000','30000','40000'};

results_dir=strcat( P_HOME, {'/Results/dcprogs/Exp1bi','/Results/dcprogs/Exp1bii', ...
    '/Results/dcprogs/Exp1biii','/Results/dcprogs/Exp1ciii','/Results/dcprogs/Exp1bv', ...
    '/Results/dcprogs/Exp1bvi'});
fig=plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp1b_allparams']);
close(fig);
clearvars -except P_HOME width height parameter_keys param_names true1_parameters;

%%Varying replicates - contrast the profile likelihoods of a pathelogical amount
%%of data with a reasonable amount
results_dir=strcat( P_HOME, {'/Results/dcprogs/Exp1bii','/Results/dcprogs/Exp1bii_r2', ...
    '/Results/dcprogs/Exp1bii_r3','/Results/dcprogs/Exp1bii_r4'});
leg={'r1','r2','r3','r4'};
colours = {'r','b','g','y'};
fig=plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp1b_1000_intervals_replicates']);
close(fig);
clearvars -except P_HOME width height parameter_keys param_names true1_parameters;

results_dir=strcat( P_HOME, {'/Results/dcprogs/Exp1biii','/Results/dcprogs/Exp1biii_r2', ...
    '/Results/dcprogs/Exp1biii_r3','/Results/dcprogs/Exp1biii_r4'});
leg={'r1','r2','r3','r4'};
colours = {'r','b','g','y'};
fig=plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp1b_10000_intervals_replicates']);
close(fig);
clearvars -except P_HOME width height parameter_keys param_names true1_parameters;


%%VARYING RESOLUTION TIME
experiments={'1ci','1cii','1ciii','iciv','1cv'};
colours = {'r','b','g','y','c'};
leg={'0','10','25','50','100'};
results_dir= strcat( P_HOME, {'/Results/dcprogs/Exp1ci','/Results/dcprogs/Exp1cii', '/Results/dcprogs/Exp1ciii', ...
'/Results/dcprogs/Exp1civ','/Results/dcprogs/Exp1cv'});
fig = plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp1c_data']);
close(fig);
%end of the cell so clear away unneeded params
clearvars -except P_HOME true1_parameters param_names xlims parameter_keys;

%%Impact of multiple concentrations on 9 parameter model

load([P_HOME '/Results/dcprogs/Exp2f/Exp2f_31102013.mat'])
f=figure();
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(fitted_params(:,ind),40);
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2f_allparams_add_conc']);
close(f);
clearvars -except P_HOME true1_parameters;

%% 10 parameter model
%%REMOVING A CONSTRAINT AND INTRODUCING NON-IDENTIFIABILITY
parameter_keys=[1,2,3,4,5,6,8,11,13,14];
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{+2a}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};

load([P_HOME '/Results/dcprogs/Exp2a/Exp2a_23102013.mat'])
f=figure();
set(f, 'Position',[0 0 3000 400])
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 6e8],[0 5000],[0 15000],[0 6e8]};
for i=1:2;
    for j=1:5;
        ind =j+(5*(i-1));
        subplot(2,5,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);       
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(param_names{ind},'interpreter','latex');
        xlim(xlims{ind})
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2a_data']);
close(f);

%we can profile these modes...
mode1=fitted_params(:,1)<2500;
mode2=(fitted_params(:,1)>10000 & fitted_params(:,1)<30000);
%means for the rate parameters of mode 1
fprintf('%s\n','mode1')
fprintf('%.16f\n',mean(fitted_params(mode1,:)))

%means for the rate parameters of mode 2
fprintf('%s\n','mode2')
fprintf('%.16f\n',mean(fitted_params(mode2,:)))

f=figure();
modal_params=[1 2 6 7 9];
for i=1:5;
    subplot(1,5,i);
    [n1,xout1]=hist(fitted_params(mode1,modal_params(i)),20);
    b1=bar(xout1,n1,'r');
    set(b1,'edgecolor','none')
    [n2,xout2]=hist(fitted_params(mode2,modal_params(i)),20);
    hold on;b2=bar(xout2,n2,'b');
    set(b2,'edgecolor','none')
    title(param_names{modal_params(i)},'interpreter','latex');
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2a_data_modes']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%profile likelihoods for the slow mode

f=figure();
set(f, 'Position',[0 0 1000 1000])
chi1 = chi2inv(0.95,1);
for i=1:5;
    for j=1:2;
        ind =j+(2*(i-1));
        load([P_HOME '/Results/dcprogs/Exp2ai/parameter_key_' num2str(parameter_keys(ind)) '.mat'])
        
        subplot(5,2,ind);
        plot(profiles(1,:),profile_likelihoods); %x axis in log space
        hold on;
        plot(log(true1_parameters(parameter_keys(ind))),min(profile_likelihoods),'rp');        
        %range for the likelihood based approxomation
        range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
        line([min(profiles(1,range)) min(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([max(profiles(1,range)) max(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2a_pl_allparams']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%%Now we vary the number of concentrations
%1,000 likelihood fits 1,000 random low and high conc data sets from Guess
%2

load([P_HOME '/Results/dcprogs/Exp2i/Exp2i_31102013.mat'])
f=figure();
set(f, 'Position',[0 0 3000 400])
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 6e8],[0 5000],[0 15000],[0 6e8]};
for i=1:2;
    for j=1:5;
        ind =j+(5*(i-1));
        subplot(2,5,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);       
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(param_names{ind},'interpreter','latex');
        xlim(xlims{ind})
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2i_fixed_start']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%%Now what happens if we vary the starting position?
load([P_HOME '/Results/dcprogs/Exp2g/Exp2g_31102013.mat'])
f=figure();
set(f, 'Position',[0 0 3000 400])
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 6e8],[0 5000],[0 15000],[0 6e8]};
for i=1:2;
    for j=1:5;
        ind =j+(5*(i-1));
        subplot(2,5,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);       
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(param_names{ind},'interpreter','latex');
        xlim(xlims{ind})
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2g_random_start']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%%Determine mode and Profile likelihoods 
load([P_HOME '/Results/dcprogs/Exp2g/Exp2g_31102013.mat'])
mode1=fitted_params(:,1)<2500;
mode2=(fitted_params(:,1)>10000 & fitted_params(:,1)<30000);
%means for the rate parameters of mode 1
fprintf('%s\n','mode1')
fprintf('%.16f\n',mean(fitted_params(mode1,:)))

%means for the rate parameters of mode 2
fprintf('%s\n','mode2')
fprintf('%.16f\n',mean(fitted_params(mode2,:)))

f=figure();
modal_params=[1 2 6 7 9];
for i=1:5;
    subplot(1,5,i);
    [n1,xout1]=hist(fitted_params(mode1,modal_params(i)),20);
    b1=bar(xout1,n1,'r');
    set(b1,'edgecolor','none')
    [n2,xout2]=hist(fitted_params(mode2,modal_params(i)),20);
    hold on;b2=bar(xout2,n2,'b');
    set(b2,'edgecolor','none')
    title(param_names{modal_params(i)},'interpreter','latex');
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2g_data_modes']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%%profile likelihoods for 10 parameters, slow mode

f=figure();
set(f, 'Position',[0 0 1000 1000])
chi1 = chi2inv(0.95,1);
for i=1:5;
    for j=1:2;
        ind =j+(2*(i-1));
        load([P_HOME '/Results/dcprogs/Exp2k/parameter_key_' num2str(parameter_keys(ind)) '.mat'])
        
        subplot(5,2,ind);
        plot(profiles(1,:),profile_likelihoods); %x axis in log space
        hold on;
        plot(log(true1_parameters(parameter_keys(ind))),min(profile_likelihoods),'rp');
        %range for the likelihood based approxomation
        range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
        line([min(profiles(1,range)) min(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([max(profiles(1,range)) max(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
        line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
        hold off;
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp2k_pl_allparams']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%show in comparison to the single concnetration profile likelihoods
experiments={'30nm','30nm and 10um'};
colours = {'r','b'};
leg={'Single','Double'};
width=5;
height=2;
results_dir= strcat( P_HOME, {'/Results/dcprogs/Exp2ai','/Results/dcprogs/Exp2k'});
fig = plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Adding_conc_10_param_pl']);
close(fig);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%show the difference in profile likelihood condfidence intervals
f=figure();
set(f, 'Position',[0 0 1000 1000])
chi1 = chi2inv(0.95,1);

%plot the single concnetration dataset

results_dir={'Exp2ai','Exp2k'};
for l=1:2
    for i=1:5;
        for j=1:2;
            ind =j+(2*(i-1));
            load([P_HOME strcat('/Results/dcprogs/',results_dir{l},'/parameter_key_', num2str(parameter_keys(ind)), '.mat')])      
            subplot(5,2,ind);
            hold on;
            [min_lik,I] = min(profile_likelihoods);

            plot(log(true1_parameters(parameter_keys(ind))),l,'rp');
            plot(profiles(1,I),l,'gp');

            %range for the likelihood based approxomation
            range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
            lower_idx = find(range, 1, 'first');
            upper_idx = find(range, 1, 'last');

            lower_ci = 1;
            upper_ci = log(10e10);
            threshold=min_lik+(chi1/2);
            if lower_idx > 1  
                %we can establish a lowed bounded confidence interval
                lower_ci = calc_root(profiles(1,lower_idx-1),profiles(1,lower_idx),profile_likelihoods(lower_idx-1)-threshold,profile_likelihoods(lower_idx)-threshold);

            end

            if upper_idx < length(profile_likelihoods)
                %we can establish a upper bounded confidence interval
                upper_ci = calc_root(profiles(1,upper_idx),profiles(1,upper_idx+1),profile_likelihoods(upper_idx)-threshold,profile_likelihoods(upper_idx+1)-threshold);          


            end

            mid = (lower_ci+upper_ci)/2;
            rectangle('Position',[lower_ci,l-0.25 ,upper_ci-lower_ci, 0.5])
            %errorbar(l,(lower_ci+upper_ci)/2,mid-lower_ci,upper_ci-mid);
            xlim([profiles(1,1),profiles(1,end)]);
            ylim ([0 3])

            hold off;
            title(param_names{ind},'interpreter','latex');
            set(gca,'YTick',[1:2])
            set(gca,'YTickLabel',{'conc 1','conc 2'})
        end ;
    end
end

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Expmulticonc_pl_intervals']);
close(f);
clearvars -except P_HOME true1_parameters parameter_keys xlims param_names;

%show in comparison to the low concnetrations vs low-high concs profile likelihoods
experiments={'10nm 30nm and 100nm','30nm and 10um'};
colours = {'r','b'};
leg={'Low concs','High concs'};
width=5;
height=2;
results_dir= strcat( P_HOME, {'/Results/dcprogs/Exp2l','/Results/dcprogs/Exp2k'});
fig = plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys);
print(fig,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Low_verus_high_concs']);
close(fig);


%confidence intervals
f=figure();
set(f, 'Position',[0 0 1000 1000])
chi1 = chi2inv(0.95,1);

results_dir={'Exp2l','Exp2k'};
for l=1:2
    for i=1:5;
        for j=1:2;
            ind =j+(2*(i-1));
            load([P_HOME strcat('/Results/dcprogs/',results_dir{l},'/parameter_key_', num2str(parameter_keys(ind)), '.mat')])      
            subplot(5,2,ind);
            hold on;
            [min_lik,I] = min(profile_likelihoods);

            plot(log(true1_parameters(parameter_keys(ind))),l,'rp');
            plot(profiles(1,I),l,'gp');

            %range for the likelihood based approxomation
            range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
            lower_idx = find(range, 1, 'first');
            upper_idx = find(range, 1, 'last');

            lower_ci = 1;
            upper_ci = log(10e10);
            threshold=min_lik+(chi1/2);
            if lower_idx > 1  
                %we can establish a lowed bounded confidence interval
                lower_ci = calc_root(profiles(1,lower_idx-1),profiles(1,lower_idx),profile_likelihoods(lower_idx-1)-threshold,profile_likelihoods(lower_idx)-threshold);

            end

            if upper_idx < length(profile_likelihoods)
                %we can establish a upper bounded confidence interval
                upper_ci = calc_root(profiles(1,upper_idx),profiles(1,upper_idx+1),profile_likelihoods(upper_idx)-threshold,profile_likelihoods(upper_idx+1)-threshold);          


            end

            mid = (lower_ci+upper_ci)/2;
            rectangle('Position',[lower_ci,l-0.25 ,upper_ci-lower_ci, 0.5])
            %errorbar(l,(lower_ci+upper_ci)/2,mid-lower_ci,upper_ci-mid);
            xlim([profiles(1,1),profiles(1,end)]);
            ylim ([0 3])

            hold off;
            title(param_names{ind},'interpreter','latex');
            set(gca,'YTick',[1:2])
            set(gca,'YTickLabel',{'low concs','low+high conc'})
        end ;
    end
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Low_verus_high_concs_intervals']);
close(f);

clearvars -except P_HOME true1_parameters;

%% 13 Parameter model - dependent binding sites
%%ESTIMATING 13 RATES INTRODUCING NON-IDENTIFIABILITY
parameter_keys=[1,2,3,4,5,6,7,8,9,10,11,13,14];
load([P_HOME '/Results/dcprogs/Exp4a/Exp4a_24102013.mat'])
f=figure();
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-2a}$','$k_{+2a}$','$k_{-2b}$','$k_{+2b}$ ','$k_{-1a}$','$k_{-1b}$','$k_{+1b}$'};
set(f, 'Position',[0 0 2000 400])
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[500 5000],[0 6e8],[500 15000],[0 6e8],[0 5000],[0 30000],[0 1e10]};
for i=1:3;
    for j=1:4;
        ind =j+(4*(i-1));
        subplot(3,5,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        hold on;
        plot(true1_parameters(parameter_keys(ind)),0,'rp');
        hold off;
        title(param_names{ind},'interpreter','latex');
        xlim(xlims{ind})
    end
end
ind=13;
subplot(3,5,ind);
plt_limit=xlims{ind};
hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
hist(hist_data,40);
hold on;
plot(true1_parameters(parameter_keys(ind)),0,'rp');
hold off;
totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
title(param_names{ind},'interpreter','latex');
xlim(xlims{ind})

print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp4a_data_allparams']);

%we can profile these modes...
mode1=fitted_params(:,1)<2500;
mode2=(fitted_params(:,1)>10000 & fitted_params(:,1)<30000);
%means for the rate parameters of mode 1
fprintf('%.16f\n',mean(fitted_params(mode1,:)))

%means for the rate parameters of mode 2
fprintf('%.16f\n',mean(fitted_params(mode2,:)))

modal_params=[1 2 9 10 13];
for i=1:5;
    subplot(1,5,i);
    [n1,xout1]=hist(fitted_params(mode1,modal_params(i)),20);
    b1=bar(xout1,n1,'r');
    set(b1,'edgecolor','none')
    [n2,xout2]=hist(fitted_params(mode2,modal_params(i)),20);
    hold on;b2=bar(xout2,n2,'b');
    set(b2,'edgecolor','none')
    title(param_names{modal_params(i)},'interpreter','latex');
end
print(f,'-depsc',[P_HOME '../../../Written/thesis_1/Figures/Exp4a_data_modes']);
clearvars -except P_HOME true1_parameters;

