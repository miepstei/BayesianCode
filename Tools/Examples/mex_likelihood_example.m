datafile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/TestData/CH82.scn';
paramsfile='/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Tools/Mechanisms/model_params_CH82_1.mat';

load(paramsfile);

dc=DataController();

[~,test_params.data]=dc.read_scn_file(datafile);
test_params.data.intervals=test_params.data.intervals/1000;

test_params.conc=concentration;
test_params.tres=tres;
test_params.tcrit=tcrit;

resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
test_params.bursts=bursts;
test_params.islogspace=true;
test_params.debugOn=true;
test_params.isCHS=true;
test_params.mechanism=ModelSetup(paramsfile);

%need cell array of burst times%
burstcell = [bursts.withinburst];
burstcell = {burstcell.intervals};

%need raw q-matrix%
%test_params.mechanism.updateConstrainedRates();
test_params.mechanism.updateConstrainedRates();
qmat=test_params.mechanism.setupQ(test_params.conc);
matrix=qmat.Q;

x=likelihood_mex(burstcell,matrix,test_params.tres,test_params.tcrit,test_params.mechanism.kA);