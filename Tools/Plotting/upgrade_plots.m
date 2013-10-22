%%Plots for upgrade report

%Experiment 0a - 1000 fits to a single file using Random as the
%starting point

P_HOME=getenv('P_HOME');

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

print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0a']);


f = figure();
set(f, 'Position',[0 0 1000 1000])
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 5000],[0 15000],[0 6e8]};
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(['Parameter ' param_names{ind} ' samples ' num2str(totals)],'interpreter','latex');
    end
end

print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0a_allparams']);


clearvars -except P_HOME;
%Experiment 0b - Profile likelihoods generated from random starting
%positions on one dataset



%Experiment 0c - 1000 fits to a 1000 files using Random as the
%starting point

load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])

f = figure();
set(f, 'Position',[0 0 1000 1000])

subplot(2,2,1);
hist(fitted_params(:,1),400);
title('Distribution of $\alpha_2$','interpreter','latex');
xlabel('$\alpha_2$','interpreter','latex');
xlim([0 3e4])
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


print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0c']);

%plot all of the parameters

f=figure();
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
set(f, 'Position',[0 0 1000 1000])
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 5000],[0 15000],[0 6e8]};
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        plt_limit=xlims{ind};
        hist_data = fitted_params((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)),ind);
        hist(hist_data,40);
        totals = sum((fitted_params(:,ind) > plt_limit(1) & fitted_params(:,ind) < plt_limit(2)));
        title(['Parameter ' param_names{ind} ' samples ' num2str(totals)],'interpreter','latex');
        
    end
end
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0c_allparams']);
clearvars -except P_HOME;

%Experiment 0d - fits to 1000 files using guess 1

load([P_HOME '/Results/dcprogs/Exp0d_14102013.mat'])

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


print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0d']);

%plot all of the parameters

f=figure();
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
set(f, 'Position',[0 0 1000 1000])
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        subplot(3,3,ind);
        hist(fitted_params(:,ind),40);
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0d_allparams']);
clearvars -except P_HOME;

%Experiment 0e - Profile likelihoods to one data file using guess 1


f=figure();
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
set(f, 'Position',[0 0 1000 1000])
parameter_keys=[1,2,3,4,5,6,11,13,14];%[1,2,3,4,5,6,11,13,14];
for i=1:3;
    for j=1:3;
        ind =j+(3*(i-1));
        load([P_HOME '/Results/dcprogs/Exp0v from guess 1/parameter_key_' num2str(parameter_keys(ind)) '.mat'])
        
        subplot(3,3,ind);
        plot(profiles(1,:),profile_likelihoods); %x axis in log space
        title(param_names{ind},'interpreter','latex');
    end ;
end
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0v_allparams']);
clearvars -except P_HOME;

%Experiment 0e - Profile likelihoods to one data file using mode 1

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
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
set(f, 'Position',[0 0 1000 1000])
parameter_keys=[1,2,3,4,5,6,11,13,14];%[1,2,3,4,5,6,11,13,14];
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
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0v_mode1_allparams']);
clearvars -except P_HOME;


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
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
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
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp1a_modes']);
clearvars -except P_HOME;

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

%%VARYING DATA 
width=3;
height=3;
parameter_keys=[1,2,3,4,5,6,11,13,14];
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
experiments={'1bi','1bii','1biii','1bv','1bvi'};
colours = {'r','b','g','y','c','m'};
leg={'500','1000','10000','20000','30000','40000'};

results_dir=strcat( P_HOME, {'/Results/dcprogs/Exp1bi','/Results/dcprogs/Exp1bii', ...
    '/Results/dcprogs/Exp1biii','/Results/dcprogs/Exp1ciii','/Results/dcprogs/Exp1bv', ...
    '/Results/dcprogs/Exp1bvi'});
plot_profiles(results_dir,colours,leg,param_names,width,height,length(parameter_keys),parameter_keys)
clearvars -except P_HOME width height parameter_keys param_names;


%%VARYING RESOLUTION TIME
experiments={'1ci','1cii','1ciii','iciv','1cv'};
colours = {'r','b','g','y','c'};
leg={'0','10','25','50','100'};
results_dir= strcat( P_HOME, {'/Results/dcprogs/Exp1ci','/Results/dcprogs/Exp1cii', '/Results/dcprogs/Exp1ciii', ...
'/Results/dcprogs/Exp1civ','/Results/dcprogs/Exp1cv'});
fig = plot_profiles(results_dir,colours,leg,title,width,height,length(parameter_keys),parameter_keys);
print(fig,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp1c_data']);
clearvars -except P_HOME;

%%ADDING CONCENTRATION


