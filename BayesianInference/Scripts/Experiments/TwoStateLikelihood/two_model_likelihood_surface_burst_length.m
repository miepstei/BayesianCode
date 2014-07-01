%%This script analyses the impact on a two state model of varying the
%%t_crit time used to separate bursts for the data

clear all

model = TwoStateExactIonModel();
tcrits=linspace(0.001,0.01,10);
surfaces=zeros(100,100,length(tcrits));

%True params used to generate this dataset
TRUE_PARAM_1=1000; %alpha -this is the mean of an expnential parameterisation
TRUE_PARAM_2=10000000;     %beta - i.e. not the rate

param_1 = linspace(-12,12,100);
param_2 = linspace(-12,12,100);


%these params never change for this experiment
data.tres = [0.0001 0.0001 0.0001 0.0001];
data.concs = [10^-3 10^-4 10^-5 10^-6];

data.useChs=[0 0 1 1];

%use log scales -12 to 12
tcrits=repmat(linspace(0.002,0.005,5),4,1);
burst_lengths = zeros(5,4);
data.tcrit = linspace(0.0005,0.5,20);

for k=1:length(tcrits)
    
    data.tcrit=tcrits(:,k);
    [data.bursts(1),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_3.scn'}),data.tres(1),data.tcrit(1));
    [data.bursts(2),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_4.scn'}),data.tres(2),data.tcrit(1));
    [data.bursts(3),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_5.scn'}),data.tres(3),data.tcrit(3));
    [data.bursts(4),~] = load_data(strcat(getenv('P_HOME'), {'/BayesianInference/Data/Ball_10_6.scn'}),data.tres(4),data.tcrit(4));

    burst_lengths(k,1)=length(data.bursts{1});
    burst_lengths(k,2)=length(data.bursts{2});
    burst_lengths(k,3)=length(data.bursts{3});
    burst_lengths(k,4)=length(data.bursts{4});
    fprintf('ANALYSING %i - tcrit %.4f burst lengths %.4f,%.4f,%.4f,%.4f\n', k ,tcrits(k),burst_lengths(k,1),burst_lengths(k,2),burst_lengths(k,3),burst_lengths(k,4))
    for i=1:100
        for j=1:100
            surfaces(i,j,k) = model.calcLogPosterior([exp(param_1(i))*TRUE_PARAM_1 exp(param_2(j))*TRUE_PARAM_2],data);
        end
    end
end

%set all impossible likelihoods to zero...
surfaces(isinf(surfaces))=0;

save(strcat(getenv('P_HOME'), '/BayesianInference/Results/TwoStateTcrit.mat'),'surfaces','param_1','param_2','tcrits')

%here is the animation
for k = 1:length(tcrits)
	contour(param_1,param_2,surfaces(:,:,k)',linspace(mean(mean(surfaces(:,:,k))),max(max(surfaces(:,:,k))),50));
	axis equal
	M(k) = getframe;
end
movie(M,30)





