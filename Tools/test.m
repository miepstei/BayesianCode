clear

[sim,mech]=simulate(1);
res=RecordingManipulator.imposeResolution(sim,0);
lik=Likelihood();
mhs=MetropolisHastingsSampler;
%profile on
%profile clear
tic
[a_1,t,e]=mhs.sample(mech,100,0.1,lik,res);
toc
save('/Users/michaelepstein/Dropbox/Mutley/PhD/code/bayesiancode/trunk/MarkovModel/Samples/a_1.mat', 'a_1');
%profile off
%profile viewer
return

clear

[sim,mech]=simulate(3);
res=RecordingManipulator.imposeResolution(sim,0);
lik=Likelihood();
mhs=MetropolisHastingsSampler;
tic
a_3=mhs.sample(mech,5000,0.1,lik,res);
save('/Users/michaelepstein/Dropbox/Mutley/PhD/code/bayesiancode/trunk/MarkovModel/Samples/a_3.mat', 'a_3');

toc

clear

[sim,mech]=simulate(5);
res=RecordingManipulator.imposeResolution(sim,0);
lik=Likelihood();
mhs=MetropolisHastingsSampler;
tic
a_5=mhs.sample(mech,5000,0.1,lik,res);
save('/Users/michaelepstein/Dropbox/Mutley/PhD/code/bayesiancode/trunk/MarkovModel/Samples/a_5.mat', 'a_5');

toc