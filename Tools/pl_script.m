%PL script
matlabpool open 3

%setup for experiment 1 in 2003 paper

parameter_keys=[1,2,3,4,5,6,11,13,14]; %keys for 1985 model, 9 free params
min=[500,20000,2000,10,20000,50,500,5000,200000000];
max=[24000,200000,10000,200,100000,500,3000,15000,600000000];
outfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/pl_2003_10000.mat';
datafile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Samples/Simulations/10000/data_1.scn';
mechfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Tools/Mechanisms/model_params_CS 1985_2.mat';
points=100;
a=tic; 
parallelProfileLikelihood_2003(points,parameter_keys,min,max,outfile,datafile,mechfile);
b=toc(a);
fprintf('Time taken for profile analysis 1 is %f\n',b)

datafile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Samples/Simulations/30000/data_1.scn';
outfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/pl_2003_30000.mat';
a=tic; 
parallelProfileLikelihood_2003(points,parameter_keys,min,max,outfile,datafile,mechfile);
b=toc(a);
fprintf('Time taken for profile analysis 2 is %f\n',b)


datafile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Samples/Simulations/40000/data_1.scn';
outfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/pl_2003_40000.mat';
a=tic; 
parallelProfileLikelihood_2003(points,parameter_keys,min,max,outfile,datafile,mechfile);
b=toc(a);
fprintf('Time taken for profile analysis 3 is %f\n',b)

%setup for experiment 1 in 2003 paper with relaxed constraint
%parameter_keys=[1,2,3,4,5,6,8,11,13,14]; %keys for 1985 model, 10 free params
%min=[500,20000,2000,10,20000,50,20000,500,5000,200000000];
%max=[24000,200000,10000,200,100000,200000000,500,3000,15000,600000000];
%outfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Results/pl_2003_unconstrained.mat';
%mechfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Tools/Mechanisms/model_params_CS 1985 k_+2a unconstrained_1.mat';
%a=tic; 
%parallelProfileLikelihood_2003(points,parameter_keys,min,max,outfile,datafile,mechfile);
%b=toc(a);
%fprintf('Time taken for profile analysis 1 is %f\n',b)

matlabpool close
