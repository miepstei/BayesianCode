results_file='/Users/michaelepstein/Dropbox/Academic/PhD/Code/gmcmc-fork/results/ION_SevenState_Syn_Posterior_25.h5';

temps=[1;10;25];
for i=1:length(temps)

    temperature = strcat('/Temperature',num2str(temps(i)));

    %log-likelihood samples log(y|\theta,t)
    LogLikelihood=h5read(results_file,strcat(temperature,'/LL'));
    params = h5read(results_file,strcat(temperature,'/Params'))';
    [bandwidth,density,X,Y] = kde2d(params(:,1:2));
    subplot(3,1,length(temps)-(i-1)); contour3(X,Y,density,50); title(strcat('Temperature ', num2str(temps(i))))
    set(gca,'View',[-9.5 46])
    %figure; scatter3(params(:,1),params(:,2),LogLikelihood); title(strcat('Temperature ', num2str(temps(i))))
end