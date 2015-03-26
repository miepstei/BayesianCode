%% This is a selection of plots to show the predictive distributions of an 
% ion-channel parameterisation of the 10-param SevenState model

%% load the true param values and the guesses
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));

%Preconditioned MALA data from synthetic dataset...
preconditioned_rwmh = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment44_1206427105.mat');
rwmh = load(preconditioned_rwmh);
posterior_density_plot=figure;
for i=1:10
    subplot(5,2,i)
    hist (rwmh.samples.params(rwmh.SamplerParams.Burnin+1:end,i),20)
    title(sprintf('$%s$',param_names{i}),'Interpreter','latex')
    limits = ylim;
    line([true1(ten_param_keys(i)),true1(ten_param_keys(i))],[limits(1),limits(2)],'LineStyle','--','Color','r')
    line([rwmh.x(i),rwmh.x(i)],[limits(1),limits(2)],'LineStyle','--','Color','g')
end
PlotNByM(posterior_density_plot,2,5,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/posterior_parameters'])
%% Sample from the posterior distribution generated
posterior_samples = datasample(rwmh.samples.params(rwmh.SamplerParams.Burnin+1:end,:),100);

%as a shortcut we are using dc-pyps to generate the distributions
open_density_plot=figure;
closed_density_plot=figure;

for conc_no=1:length(rwmh.filenames)
    %data from experiment 37
    [~,data]=DataController.read_scn_file(rwmh.filenames{conc_no});
    data.intervals=data.intervals/1000;
    tres=rwmh.data.tres(conc_no);
    conc=rwmh.data.concs(conc_no);
    resolvedData = RecordingManipulator.imposeResolution(data,tres);
    [open, shut] = RecordingManipulator.getPeriods(resolvedData);

    %% Open time distributions
    kA=rwmh.model.kA;
    kF=4;

    figure(open_density_plot);
    subplot(2,2,conc_no)
    open_root_samples = zeros(length(posterior_samples),kA);
    open_area_samples = zeros(length(posterior_samples),kA);
    for i=1:length(posterior_samples)
        params = posterior_samples(i,:);
        Q=rwmh.model.generateQ(params',conc);
        [t, open_pdf, open_areas ,open_roots] =  open_asymptotic_pdf(Q,kA,kF,tres);
        open_root_samples(i,:) = open_roots;
        open_area_samples(i,:) = open_areas;
        
        semilogx(t*1000,open_pdf,'r','LineWidth',1);hold on;

        %% Closed time distibution
        %figure;
        %for i=0:999
        %    load(strcat(getenv('P_HOME'),'/../dc-pyps-new/','posterior_predictive',num2str(i),'.mat'));
        %    semilogx(closed_distributions.t,closed_scaled_pdf.asy_pdf);hold on;
        %end
        %semilogx(closed_times.x*1000,closed_times.y,'r','LineWidth',3)
    end
    [buckets,frequency,dx] =  Histogram(open.intervals,tres);
    semilogx(buckets*1000,frequency./(length(open.intervals)*log10(dx)*2.30259),'LineWidth',3);
    title(strcat(num2str(conc),' M'))
    xlabel('Time, ms')
    hold off;
    
    %% Distribution over time constants
%     figure;
%     for i=1:kA
%         [f, x]=hist(-1./open_root_samples(:,i),20); 
%         subplot(kA,1,i);bar(x,f/trapz(x,f));
%     end
% 
%     % Distribution over areas
%     figure;
%     for i=1:kA
%         [f, x]=hist(open_area_samples(:,i),20); 
%         subplot(kA,1,i);bar(x,f/trapz(x,f));
%     end

    %% Closed intervals
    figure(closed_density_plot);
    subplot(2,2,conc_no)
    for i=1:length(posterior_samples)
        params = posterior_samples(i,:);
        Q=rwmh.model.generateQ(params',conc);
        [t, closed_pdf, closed_areas ,closed_roots] =  close_asymptotic_pdf(Q,kA,kF,tres);
        semilogx(t*1000,closed_pdf,'r','LineWidth',1);hold on;
    end

    [buckets,frequency,dx] =  Histogram(shut.intervals,tres);
    semilogx(buckets*1000,frequency./(length(shut.intervals)*log10(dx)*2.30259),'LineWidth',3);
    title(strcat(num2str(conc),' M'))
    xlabel('Time, ms')
    hold off;
end

PlotNByM(open_density_plot,1,3,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/posterior_open_times'])
PlotNByM(closed_density_plot,1,3,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/posterior_closed_times'])
clear all

%% Fitting from real Experimental data
load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'));
preconditioned_rwmh_experimental = strcat(getenv('P_HOME'),'/BayesianInference/Results/Thesis/Experiment46_1172881560.mat');
rwmh_exp = load(preconditioned_rwmh_experimental);

posterior_density_plot=figure;
%mle_params=[1.96361631e+03 4.46454311e+04 1.17589225e+04 9.73767638e-01 6.47226246e+08 1.48450066e+02 3.05618849e+07 2.24787766e-03 1.76564027e+04   5.73135919e+07]';
for i=1:10
    subplot(5,2,i)
    hist (rwmh_exp.samples.params(rwmh_exp.SamplerParams.Burnin+1:end,i),20)
    title(sprintf('$%s$',param_names{i}),'Interpreter','latex')
    limits = ylim;
    %line([mle_params(i),mle_params(i)],[limits(1),limits(2)],'LineStyle','--','Color','r')
    %line([rwmh_exp.x(i),rwmh_exp.x(i)],[limits(1),limits(2)],'LineStyle','--','Color','g')
end
PlotNByM(posterior_density_plot,2,5,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/experimental_posterior_parameters'])
%% Sample from the posterior distribution generated
posterior_samples = datasample(rwmh_exp.samples.params(rwmh_exp.SamplerParams.Burnin+1:end,:),100);

%as a shortcut we are using dc-pyps to generate the distributions
open_density_plot=figure;
closed_density_plot=figure;

intervals = load([getenv('P_HOME') '/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'],'open_intervals','closed_intervals');

for conc_no=1:length(intervals.closed_intervals)
    
    conc=rwmh_exp.data.concs(conc_no);
    tres=rwmh_exp.data.tres(conc_no);
    %data from experiment 40
    open_intervals = intervals.open_intervals{conc_no}';
    shut_intervals = intervals.closed_intervals{conc_no}';
    %% Open time distributions
    kA=rwmh_exp.model.kA;
    kF=4;

    figure(open_density_plot);
    subplot(1,3,conc_no)
    open_root_samples = zeros(length(posterior_samples),kA);
    open_area_samples = zeros(length(posterior_samples),kA);
    for i=1:length(posterior_samples)
        params = posterior_samples(i,:);
        %params=[1945.86	49067.8	6839.56	0.924884	79660.2	11.121 5.24E+06	162.7	15092.8	7.52E+07]';
        Q=rwmh_exp.model.generateQ(params',conc);
        [t, open_pdf, open_areas ,open_roots] =  open_asymptotic_pdf(Q,kA,kF,tres);
        [open_p, ~, ~] = exact_pdf(Q,kA,kF,t,tres);
        open_root_samples(i,:) = open_roots;
        open_area_samples(i,:) = open_areas;
        
        %semilogx(t*1000,open_pdf,'r','LineWidth',1);hold on;
        semilogx(t*1000,open_p,'r','LineWidth',1);hold on;
        %% Closed time distibution
        %figure;
        %for i=0:999
        %    load(strcat(getenv('P_HOME'),'/../dc-pyps-new/','posterior_predictive',num2str(i),'.mat'));
        %    semilogx(closed_distributions.t,closed_scaled_pdf.asy_pdf);hold on;
        %end
        %semilogx(closed_times.x*1000,closed_times.y,'r','LineWidth',3)
    end
    
    %superimpose the MLE from the fits...
    Q=rwmh_exp.model.generateQ(mle_params,conc);
    [open_p, ~, ~] = exact_pdf(Q,kA,kF,t,tres); 
    semilogx(t*1000,open_p,'g','LineWidth',1);hold on;
    
    %now the data
    [buckets,frequency,dx] =  Histogram(open_intervals,tres);
    semilogx(buckets*1000,frequency./(length(open_intervals)*log10(dx)*2.30259),'LineWidth',3);
    title(strcat(num2str(conc),' M'))
    xlabel('Time, ms')
    hold off;
    
    %% Distribution over time constants
%     figure;
%     for i=1:kA
%         [f, x]=hist(-1./open_root_samples(:,i),20); 
%         subplot(kA,1,i);bar(x,f/trapz(x,f));
%     end
% 
%     % Distribution over areas
%     figure;
%     for i=1:kA
%         [f, x]=hist(open_area_samples(:,i),20); 
%         subplot(kA,1,i);bar(x,f/trapz(x,f));
%     end

    %% Closed intervals
%     figure(closed_density_plot);
%     subplot(3,1,conc_no)
%     %for i=1:length(posterior_samples)
%         %params = posterior_samples(i,:);
%         params=[1945.86	49067.8	6839.56	0.924884	79660.2	11.121 5.24E+06	162.7	15092.8	7.52E+07]';
%         Q=rwmh_exp.model.generateQ(params',conc);
%         [t, closed_pdf, closed_areas ,closed_roots] =  close_asymptotic_pdf(Q,kA,kF,tres);
%         semilogx(t*1000,closed_pdf,'r','LineWidth',1);hold on;
%     %end
% 
%     [buckets,frequency,dx] =  Histogram(shut_intervals,tres);
%     semilogx(buckets*1000,frequency./(length(shut_intervals)*log10(dx)*2.30259),'LineWidth',3);
%     title(strcat(num2str(conc),' M'))
%     xlabel('Time, ms')
%     hold off;
end

%PlotNByM(open_density_plot,3,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/experimental_posterior_open_times'])
%PlotNByM(closed_density_plot,3,1,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter5/experimental_posterior_closed_times'])

