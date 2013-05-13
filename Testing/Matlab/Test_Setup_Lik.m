
lik = ExactLikelihood();
resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
test_params.bursts=bursts;
test_params.islogspace=true;
test_params.debugOn=true;
test_params.conc=1e-7;
test_params.tres=0.0001;
test_params.tcrit=0.004;
test_params.isCHS=true;

init_params=test_params.mechanism.getParameters(true);
lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);

