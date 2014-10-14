a=rand(10,1);
b=rand(10,1);
c=rand(10,1);

fig = figure;
subplot(3,1,1)
plot(a)
subplot(3,1,2)
plot(b)
subplot(3,1,3)
plot(c)

PlotNByM(fig,2,2,[getenv('P_HOME') '/BayesianInference/Plotting/test'])