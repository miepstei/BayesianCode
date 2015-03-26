%we just want the experimental data for lowest concentration recording
data=load(strcat(getenv('P_HOME'),'/BayesianInference/Data/Hatton2003/Figure11/AchRealData.mat'));
MSEC=1000;

%open time distribution
[open_intervals, shut_intervals] = RecordingManipulator.getPeriods(data.resolved_data{1});
f=figure;
[buckets,frequency,dx] =  Histogram(open_intervals.intervals,data.tres(1));
semilogx(buckets*MSEC,frequency./(length(open_intervals.intervals)*log10(dx)*2.30259),'LineWidth',2);
hold on;  
title(strcat('Concentration = ', num2str(data.concs(1)),' M'),'FontSize',16)
xlabel('Duration, milliseconds')
ylabel('Density')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/open_dist'))
close(f)

%shut time distribution
f=figure;
[buckets,frequency,dx] =  Histogram(shut_intervals.intervals,data.tres(1));
semilogx(buckets*MSEC,frequency./(length(shut_intervals.intervals)*log10(dx)*2.30259),'LineWidth',2);
hold on;  
title(strcat('Concentration = ', num2str(data.concs(1)),' M'),'FontSize',16)
xlabel('Duration, milliseconds')
ylabel('Density')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/shut_dist'))
close(f)

%bivariate
f=figure;
[o, s] = RecordingManipulator.getPeriods(data.resolved_data{1});
plotdata=[ o.intervals' s.intervals'];        
plotdata=plotdata*MSEC;
logMsData=log10(plotdata);
min_axis = [-2 , -2];
max_axis = [2 , 4];
[~,density,open_axis,shut_axis] = kde2d(logMsData, 2^8,min_axis,max_axis);
surf(open_axis,shut_axis,density,'LineStyle','none'), view([50,50])
xlim([min_axis(1) max_axis(1)])
ylim([min_axis(2) max_axis(2)])
zlim([0 1])
title(strcat('Concentration = ', num2str(data.concs(1)),' M'),'FontSize',16)
ylabel('Shut Time, log(ms)')
xlabel('Open Time, log(ms)')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/bivariate'))
close(f)

%conditional open time distribution
f=figure;
shut_range = [2.5e-5,0.1/1000];
conditional_open = RecordingManipulator.getSuceedingPeriodsWithRange(data.resolved_data{1},1,shut_range);
[cbuckets,cfrequency,cdx] =  Histogram(conditional_open,data.tres(1));
semilogx(cbuckets*MSEC,cfrequency./(length(conditional_open)*log10(cdx)*2.30259),'LineWidth',2);
hold on;

%open data again
[buckets,frequency,dx] =  Histogram(open_intervals.intervals,data.tres(1));
semilogx(buckets*MSEC,frequency./(length(open_intervals.intervals)*log10(dx)*2.30259),'LineWidth',2);

%plot chart
title(strcat('Concentration = ', num2str(data.concs(1)),' M'),'FontSize',16)
xlabel('Duration, milliseconds')
ylabel('Density')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/cond_open'))
close(f)

%mean open time dist
f=figure;
tint = [0.025 0.05;0.05 0.1; 0.1 0.2; 0.2 2; 2 20; 20 200; 200 2000;]/1000;

for i = 1:size(tint,1)
    succeeding_openings = RecordingManipulator.getSuceedingPeriodsWithRange(data.resolved_data{1},1,tint(i,:));
    empirical_mean_open(i) = mean(succeeding_openings);
    empirical_mean_close(i) =  mean(RecordingManipulator.getPeriodsWithRange(data.resolved_data{1},0,tint(i,:)));
    empirical_std_open(i) = std(succeeding_openings);
    empirical_n_open(i) = length(succeeding_openings); 
end
scatter(empirical_mean_close*MSEC,empirical_mean_open*MSEC)
hold on;
errorbar(empirical_mean_close*MSEC,empirical_mean_open*MSEC,empirical_std_open*MSEC./sqrt(empirical_n_open))
hold off
title(strcat('Concentration = ', num2str(data.concs(1)),' M'),'FontSize',16)

set(gca,'XScale','log');
xlabel('log(milliseconds)')
ylabel('milliseconds')
Plot1By1(f,0,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/mean_open_dist'))
close(f)

%% P-open

%conc(microM)	Popen	SDM	
concs = [3,5,6.4,10,20,30,64,100];
Popen = [0.25,0.39,0.55,0.69,0.85,0.92,0.93,0.93];
SDM = [0.044612218,0.077674535,0.084852814,0.052249402,0.031112698,0.014142136,0.011547005,0.01];
f = figure;
scatter(concs,Popen)
hold on;
errorbar(concs,Popen,SDM)
hold off
title(strcat('P-open curve for Acetylcholine'),'FontSize',16)
set(gca,'XScale','log');
xlabel('log(Concentration), \muM')
ylabel('P-open')
Plot1By1(f,0,strcat(getenv('P_HOME'),'/../../Written/ThesisCorrected/Figures/Chapter2/p-open'))
close(f)
 

