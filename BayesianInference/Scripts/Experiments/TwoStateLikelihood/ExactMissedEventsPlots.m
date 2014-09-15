%%This script analyses the impact on a two state model of multiple
%%concentrations on the exact missed events likelihood

clear all

model = TwoState_2param_AT();
surface=zeros(100,100);

%True params used to generate this dataset
TRUE_PARAM_1=1000; %alpha -this is the mean of an expnential parameterisation
TRUE_PARAM_2=10000000;     %beta - i.e. not the rate


data.tres = [0.0001 0.0001 0.0001 0.0001];
data.concs = [10^-3 10^-4 10^-5 10^-6];
data.tcrit = [1 1 1 1];
data.useChs=[0 0 1 1];
%use log scales -12 to 12

param_1 = linspace(-12,12,100); %mu_o - alpha
param_2 = linspace(-12,12,100); %mu_c - beta

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

for row=1:100
    for col=1:100
        surface(row,col) = model.calcLogLikelihood([exp(param_1(col))*TRUE_PARAM_1 exp(param_2(row))*TRUE_PARAM_2],data);
    end
end


%set all impossible likelihoods to zero...
surface(isinf(surface))=NaN;
f=figure('Visible','off');
%need to flip these axes around to make them comparable to Ball's 1/rate
%notation, and reverse the axes...
contour(param_1,param_2,surface,linspace(max(max(surface))-50000,max(max(surface)),10))
ylabel('$\mathrm{log}(\hat{\mu_{c}}/\mu_{c})$','Interpreter','LaTex','FontSize',15);
xlabel('$\mathrm{log}(\hat{\mu_{o}}/\mu_{o})$','Interpreter','LaTex','FontSize',15);
set(gca,'YDir','Reverse')
set(gca,'XDir','Reverse')
Plot1By1(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/multiple_concs_exact_missed_events'])
%print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/multiple_concs_exact_missed_events']);
close(f)


%return parameters bak to normal
param_1 = linspace(-12,12,100); %mu_o - alpha
param_2 = linspace(-12,12,100); %mu_c - beta
data.tres = [0.0001 0.0001 0.0001 0.0001];
%single concentration for comparison at M=10^-5
surface_single = zeros(100,100);
data_single.bursts(1) = data.bursts(3);
data_single.tres = 0.0001;
data_single.concs =  10^-5;
data_single.tcrit = [1];
data_single.useChs=[1];

for row=1:100
    for col=1:100
        surface_single(row,col) = model.calcLogLikelihood([exp(param_1(col))*TRUE_PARAM_1 exp(param_2(row))*TRUE_PARAM_2],data_single);
    end
end

surface_single(isinf(surface_single))=NaN;
f=figure('Visible','off');
contour(param_1,param_2,surface_single,linspace(max(max(surface_single))-30000,max(max(surface_single)),10))
ylabel('log$(\hat{\mu_{c}}$/$\mu_{c})$','Interpreter','LaTex','FontSize',10);
xlabel('log$(\hat{\mu_{o}}$/$\mu_{o})$','Interpreter','LaTex','FontSize',15);
set(gca,'YDir','Reverse')
set(gca,'XDir','Reverse')
Plot1By1(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter4/single_conc_10_5_exact_missed_events'])
%print(f,'-depsc',[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter4/single_conc_10_5_exact_missed_events']);
close(f)
save(strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEvents.mat'),'surface','param_1','param_2','surface_single')

%% create a zoomed dataset - note cahnge in parameter values to match experiments

data.tres = [ 0.000025 0.000025 0.000025 0.000025];
data.concs = [10^-3 10^-4 10^-5 10^-6];
data.tcrit = [1 1 1 1];
data.useChs=[0 0 1 1];

[data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
[data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(2));
[data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
[data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

param_1 = linspace(50,1500,100); %mu_o - alpha
param_2 = linspace(500000,1.2e+07,100); %mu_c - beta
surface_zoom=zeros(100,100);
for row=1:100
    for col=1:100
        surface_zoom(row,col) = model.calcLogPosterior([param_1(col) param_2(row)],data);
    end
end

surface_zoom(isinf(surface_zoom))=NaN;
save(strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEventsZoom.mat'),'surface','param_1','param_2','surface_zoom')
