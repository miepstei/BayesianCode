
dc=DataController();

[~,test_params.data]=dc.read_scn_file('Testing/TestData/CH82.scn');
test_params.data.intervals=test_params.data.intervals/1000;

test_params.conc=3e-8;
test_params.tres=0.0001;
test_params.tcrit=0.004;

resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
test_params.bursts=bursts;
test_params.islogspace=true;
test_params.debugOn=true;
test_params.isCHS=true;

mecs=dc.list_mechanisms('Testing/TestData/demomec.mec');

%[rate_list, cycle_mechanism, ratetitle] = dc.read_mechanism('Testing/TestData/demomec.mec',mecs.mec_struct(2));

%set constraints here
constraints=containers.Map('KeyType', 'int32','ValueType','any');
constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',11,'args',1);
constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',12,'args',1);
constraints(9)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',13,'args',1); %FIXED!
constraints(10)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',14,'args',1);
constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);

test_params.mechanism=dc.create_mechanism('Testing/TestData/demomec.mec',mecs.mec_struct(2),constraints);


init_params=test_params.mechanism.getParameters(true);

lik = ExactLikelihood();    
[open_times,closed_times,withinburst_count,l_openings] = lik.calculate_burst_parameters(bursts);
lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
likelihood=lik.calculate_likelihood_vectorised(test_params.bursts,open_times,closed_times,withinburst_count,l_openings);

disp(likelihood);

