function test_args = SetupTests()
%SetupTests is boilerplate for running the test suite
%RETURNS - a structure with test parameters in it

%test data,concentration and mechanism
set(0,'RecursionLimit',1000)
test_args.localpath=getpref('ME','matpath');
dc = DataController;
[~,data]=dc.read_scn_file(strcat(test_args.localpath,'Academic/PhD/Code/bayesiancode/trunk/MarkovModel/Testing/TestData/CH82.scn'));
test_args.conc = 0.0000001;
test_args.mechanism = DataController.read_mechanism_demo();
test_args.epsilon = 0.00000000001;
test_args.tres = 0.0001; % 100 microsec
test_args.tcrit = 0.004; %separation of time between bursts is 4000 \mus or 4ms 
test_args.isCHS = 1; % don't us CHS vectors
test_args.debug.on=1; %collect the debugging matrices


%rescale intervals into \mu(s)
test_args.data=data;
test_args.data.intervals=data.intervals/1000;


end

