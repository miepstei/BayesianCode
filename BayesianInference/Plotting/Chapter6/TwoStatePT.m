%example parallel tempering for two state model N=50

twostate_results_file=strcat(getenv('P_HOME'), '/BayesianInference/Results/TwoState/ION_TwoState_Single_Posterior_Precond_50.h5');
t=[ 5 10 20 30 40 50];
temperatures = (((1:50)/50).^5);

f=figure;
for i=1:length(t)
    Params=h5read(twostate_results_file,strcat('/Temperature',num2str(t(i)),'/Params'))';
    LL=h5read(twostate_results_file,strcat('/Temperature',num2str(t(i)),'/LL'));
    subplot(3,2,i)
    scatter(log(Params(:,1)/1000),log(Params(:,2)/10^7),'.'); xlim([-1 7]);ylim([-1 7]);title(['\beta = ' sprintf('%.4f',temperatures(t(i)))])
    
    if i==length(t)
        %label the last chart
        xlabel('$log(\frac{\hat{\alpha}}{\alpha})$','Interpreter','LaTex')
        ylabel('$log(\frac{\hat{\beta}}{\beta})$','Interpreter','LaTex')
        xlabh = get(gca,'XLabel');
        set(xlabh,'Position',get(xlabh,'Position') + [0 4 0])
    end
    %set(gca,'yaxisLocation','top')
    %text(1,3,['temp = ' sprintf('%.4f',temperatures(t(i)))]) 
    %drawnow
    %F(i) = getframe;
end

PlotNByM(f,3,2,1,12,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/two_state_single_conc_PT']);

%plot the trace for the first 1000 posterior samples
g=figure;
subplot(1,2,1)
plot(log(Params(1:1000,1)/1000))
xlabel('Iteration')
ylabel('$log(\frac{\hat{\alpha}}{\alpha})$','Interpreter','LaTex')
xlabh = get(gca,'yLabel');
set(xlabh,'Position',get(xlabh,'Position') + [2 0 0])

subplot(1,2,2)
autocorr(Params(:,1)/1000)
title('')
PlotNByM(g,1,2,0,12,[getenv('P_HOME') '/../../Written/Thesis/Figures/Chapter6/two_state_single_conc_PT_trace_and_autocorr']);

%