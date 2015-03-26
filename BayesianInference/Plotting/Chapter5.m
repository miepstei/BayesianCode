clear

rwmh = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment2_619389729.mat'));

mala = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment11_663826263.mat'));

truncated_mala = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment13_663826227.mat'));

preconditioned_mala = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment21_663830379.mat'));


%% plot convergence of second param MALA

m = mala.samples;
t= truncated_mala.samples;
f=figure('visible','off');
hold on
plot(m.params(1:end,2),'b');
plot(t.params(1:end,2),'g');
xlabel('Iteration')
ylabel('Sample of $\beta$','Interpreter','latex')
hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/MALA_2Param_Convergence']);

%% plot convergence of second param preconditioned MALA
p = preconditioned_mala.samples;
f=figure('visible','off');
hold on
plot(p.params(1:end,2),'b');
xlabel('Iteration')
ylabel('Sample of $\beta$','Interpreter','latex')
hold off
Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/MALA_Preconditioned_2Param_Convergence']);
delete(findall(0,'Type','figure'))


%% autocorrelation of Preconditioned MALA

f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};
pp=preconditioned_mala.SamplerParams;
for i=1:2
    subplot(1,2,i)
    autocorr(p.params(pp.Burnin+1:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param(i),'interpreter','latex')
end
Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/MALA_Preconditioned_2Param_Autocorrelations']);
clear


%% convergence of simplified mMALA
smmala = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment15_653170210.mat'));
sm=smmala.samples;
smp=smmala.SamplerParams;

mcw = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/ExperimentA_669752074.mat'));
mcws = mcw.samples;

lik_surface = strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEventsZoom.mat');
load(lik_surface)

f=figure('Visible','off');
contour((param_1),(param_2),surface_zoom,50)
hold on
plot(sm.params(1:1000,1),sm.params(1:1000,2))
plot(mcws.params(1:1000,1),mcws.params(1:1000,2),'g')
xlabel('$\alpha$','Interpreter','latex')
ylabel('$\beta$','Interpreter','latex')
hold off

Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter5/smMALA_2Param_LogSurface']);


%% autocorrelation of simplified mMALA
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};

for i=1:2
    subplot(1,2,i)
    autocorr(sm.params(smp.Burnin+1:end,i),100)
    title('')
    xlabel('Lag')
    ylabel(param(i),'interpreter','latex')
end
Plot1By2(f,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/smMALA_2Param_Autocorrelations']);
clear

%% Adaptive MCMC
adaptive = matfile(strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment17_653865132.mat'));
ad = adaptive.samples;
adp = adaptive.SamplerParams;

lik_surface = strcat(getenv('P_HOME'),'/BayesianInference/Results/ExactLikelihood/TwoStateExactMissedEventsZoom.mat');
load(lik_surface)

f=figure('Visible','off');
contour((param_1),(param_2),surface_zoom,50)
hold on
plot(ad.params(1:10000,1),ad.params(1:10000,2))
xlabel('$\alpha$','Interpreter','latex')
ylabel('$\beta$','Interpreter','latex')
hold off

Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter5/adaptive_2Param_LogSurface']);

%% Autocorrelation of Parameter 1
f=figure('Visible','off');
param = {'$\alpha$','$\beta$'};

autocorr(ad.params(adp.Burnin+1:end,1),100)
title('')
xlabel('Lag')
ylabel('$\alpha$','interpreter','latex')
hold off
Plot1By1(f,1,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter5/adaptive_2Param_Autocorrelation_Param1'])


%% Evolution of the variance and parameter 1

f=figure('Visible','off');


plot(ad.params(1:10000,1))
xlabel('$iterations$','Interpreter','latex')
ylabel('$\alpha$','Interpreter','latex')
hold off

Plot1By1(f,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/adaptive_2Param_Convergence']);

f=figure('Visible','off');
subplot(1,2,1)
semilogy(reshape(ad.covariance(1,1,1:ad.N),ad.N,1).*ad.scaleFactors(1:ad.N))
hold on
xlabel('$iterations$','Interpreter','latex')
ylabel('$proposal variance of \alpha$','Interpreter','latex')
hold off

subplot(1,2,2)
semilogy(reshape(ad.covariance(2,1,1:ad.N),ad.N,1).*ad.scaleFactors(1:ad.N))
hold on
xlabel('$iterations$','Interpreter','latex')
ylabel('proposal covariance of $\alpha$ and $\beta$','Interpreter','latex')
hold off

%global covariance for precoditioned algorithms * step size for mala
emp_mass_m = [1.2507254174186706e+02,1.1335165500977523e+05;1.1335165500977523e+05,1.2170357074513498e+10]*0.0050;
Plot1By2(f,[getenv('P_HOME') '../../../Written/Thesis/Figures/Chapter5/adaptive_2Param_varianceadaption_Param1'])

delete(findall(0,'Type','figure'))
