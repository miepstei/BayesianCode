%runs for all files in Testing/TestData dir

a=ls('test_*');
c=strsplit(a);
c=c(1:end-1); %last one is blank
params=zeros(1000,14);
likelihoods=zeros(1000,1);
fprintf ('%i Simultions to do\n',length(c))
parfor i=1:length(c)
    fprintf('Fit %i Fitting to datafile %s\n',i,c{i})
    d=strsplit(c{i},'_');
    e=strsplit(d{2},'.');
    [final_likelihood,fittedRates,min_parameters]=fit_simplex(c{i},'/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_4.mat');
    index = str2double(e{1});
    params(i,:)=fittedRates(:,2);
    likelihoods(i)=final_likelihood;
    fprintf('Fit %i SAVED, final likeihood %f %i simulations out of %i done\n\n',i,final_likelihood,i,length(c))
end
save('sim.mat','params','likelihoods');