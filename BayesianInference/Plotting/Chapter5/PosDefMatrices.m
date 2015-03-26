%plotting posdef matrices, 2 param model

load(strcat(getenv('P_HOME'),'/BayesianInference/Results/MetricTensor/Varying_h_4_4/TwoStateMT_inexactcomparison.mat'))

f=figure;
imagesc(param_1,param_2,exactposdef);colormap(gray(2));
xlabel('$\log(\hat\mu_o/\mu_o)$','Interpreter','LaTex')
ylabel('$\log(\hat\mu_c/\mu_c)$','Interpreter','LaTex')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/Thesis/Figures/Chapter5/ExactPosDef'));
close(f);

f=figure;
%-inexactposdef as we want white to represent +definate tensors
imagesc(param_1,param_2,-inexactposdef);colormap(gray(2));
xlabel('$\log(\hat\mu_o/\mu_o)$','Interpreter','LaTex')
ylabel('$\log(\hat\mu_c/\mu_c)$','Interpreter','LaTex')
Plot1By1(f,1,strcat(getenv('P_HOME'),'/../../Written/Thesis/Figures/Chapter5/InexactPosDef'));
close(f);