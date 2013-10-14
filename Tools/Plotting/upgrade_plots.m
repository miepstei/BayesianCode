%%Plots for upgrade report

%Experiment 0c - fits to 1000 random data points using Guess 1 as the
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
clearvars -except P_HOME ;


load([P_HOME '/Results/dcprogs/Exp0c_14102013.mat'])

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


print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0c']);
clearvars -except P_HOME ;


%Experiment 0d - fits to 1000 random data points using random initial
%guesses

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
        title(param_names{ind},'interpreter','latex');
        hist(fitted_params(:,ind),40);
    end ;
end
print(f,'-djpeg',[P_HOME '../../../Written/thesis_1/Figures/Exp0d_allparams']);
clear all;





