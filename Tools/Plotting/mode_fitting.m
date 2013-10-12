BINS_NUMBER=40;
[n,xout]=hist(fitted_lik_total,BINS_NUMBER);
width = xout(2)-xout(1);
xoutmin = xout-width/2;
xoutmax = xout+width/2;

%we have to assume we know the location of the modes here in the
%xoutmax/min arrays
mode1 = fitted_params_total(fitted_lik_total > xoutmin(1) & fitted_lik_total < xoutmax(1),:);
mode2 = fitted_params_total(fitted_lik_total > xoutmin(9) & fitted_lik_total < xoutmax(9),:);

figure
for i=1:9
    [nx,xout]=hist(mode1(:,i),BINS_NUMBER);
    [ny,yout]=hist(mode2(:,i),BINS_NUMBER);
    bins = unique([xout yout]);
    %need to linearly space bins
    x=linspace(min(bins),max(bins),BINS_NUMBER);
    subplot(3,3,i)
    hist(mode1(:,i),x)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
    hold on;
    hist(mode2(:,i),x)
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
end