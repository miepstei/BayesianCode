% Defaults for this blog post
width = 10;     % Width in inches
height = 10;    % Height in inches
alw = 0.75;    % AxesLineWidth
fsz = 11;      % Fontsize
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
% The new defaults will not take effect if there are any open figures. To
% use them, we close all figures, and then repeat the first example.
close all;

% The properties we've been using in the figures
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);

% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(0, 'defaultFigurePaperPosition', defsize);

P_HOME=getenv('P_HOME');
true1_parameters=[2000 52000 6000 50 50000 150 1500 2e8 10000 4e8 1500 2e8 10000 4e8];
parameter_keys=[1,2,3,4,5,6,11,13,14];
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};
xlims={[0 3e4],[0  2e5],[5000 10000],[0 100],[0 200000],[0 500],[0 5000],[0 15000],[0 6e8]};
parameter_keys=[1,2,3,4,5,6,8,11,13,14];
param_names={'$\alpha_{2}$','$\beta_{2}$','$\alpha_{1a}$','$\beta_{1a}$','$\alpha_{1b}$','$\beta_{1b}$','$k_{+2a}$','$k_{-1a}$','$k_{-1b}$ ','$k_{+1b}$'};

chi1 = chi2inv(0.95,1);

f1=figure()
figureHandle = gcf;
%# make all text in the figure to size 14 and bold

set(f1, 'Position',[0 0 1000 1000])
for j=1:2;
    load([P_HOME '/Results/dcprogs/Exp2ai/parameter_key_' num2str(parameter_keys(j)) '.mat'])
    subplot(1,2,j);
    plot(profiles(1,:),profile_likelihoods); %x axis in log space
    hold on;
    plot(log(true1_parameters(parameter_keys(j))),min(profile_likelihoods),'gp');
    %range for the likelihood based approxomation
    range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
    line([min(profiles(1,range)) min(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
    line([max(profiles(1,range)) max(profiles(1,range))],[min(profile_likelihoods) max(profile_likelihoods)],'Color','r');
    line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
    ylabel('Log Likelihood','FontSize',36)
    %set(findall(figureHandle,'type','text'),'fontSize',14,'fontWeight','bold')
    hold off;   
    title(param_names{j},'interpreter','latex','FontSize',36);
end

print(f1,'-depsc',[P_HOME '../../../Written/Presentations/SBIPresentation/PL_identifiable2.eps']);

f2=figure()
set(f2, 'Position',[0 0 1000 1000])
for j=6:7;
    load([P_HOME '/Results/dcprogs/Exp2ai/parameter_key_' num2str(parameter_keys(j)) '.mat'])
    subplot(1,2,j-5);
    plot(profiles(1,:),profile_likelihoods); %x axis in log space
    hold on;
    plot(log(true1_parameters(parameter_keys(j))),min(profile_likelihoods),'rp');
    %range for the likelihood based approxomation
    range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
    line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
    hold off;
    title(param_names{j},'interpreter','latex');
end

print(f2,'-depsc',[P_HOME '../../../Written/Presentations/SBIPresentation/PL_unidentifiable2.eps']);

f3=figure()
set(f3, 'Position',[0 0 1000 1000])
j=1; 
load([P_HOME '/Results/dcprogs/Exp2ai/parameter_key_' num2str(parameter_keys(j)) '.mat'])
%determine range for the plots

y_min = min(profile_likelihoods);
y_max = max(profile_likelihoods);

subplot(2,1,1);
plot(profiles(1,:),profile_likelihoods); %x axis in log space
hold on;
plot(log(true1_parameters(parameter_keys(j))),min(profile_likelihoods),'gp');
%range for the likelihood based approxomation
range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
line([min(profiles(1,range)) min(profiles(1,range))],[y_min y_max],'Color','r');
line([max(profiles(1,range)) max(profiles(1,range))],[y_min y_max],'Color','r');
line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
ylabel('Log Likelihood','FontSize',36)
title(param_names{j},'interpreter','latex','FontSize',36);
%set(findall(figureHandle,'type','text'),'fontSize',14,'fontWeight','bold')
hold off;   

j=6;
load([P_HOME '/Results/dcprogs/Exp2ai/parameter_key_' num2str(parameter_keys(j)) '.mat'])
subplot(2,1,2);
plot(profiles(1,:),profile_likelihoods); %x axis in log space
hold on;
plot(log(true1_parameters(parameter_keys(j))),min(profile_likelihoods),'gp');
%range for the likelihood based approxomation
range = profile_likelihoods < min(profile_likelihoods)+(0.5*chi1);
line([min(profiles(1,:)) max(profiles(1,:))],[min(profile_likelihoods)+(0.5*chi1); min(profile_likelihoods)+(0.5*chi1);],'Color','r');
ylabel('Log Likelihood','FontSize',36)
ylim([min(profile_likelihoods), min(profile_likelihoods)+(max(profile_likelihoods)-min(profile_likelihoods))*4]);
title(param_names{j},'interpreter','latex','FontSize',36);
%set(findall(figureHandle,'type','text'),'fontSize',14,'fontWeight','bold')
hold off;   
