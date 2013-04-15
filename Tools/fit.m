function bursts=fit(mechanism,datafile,t_crit)

%e.g.
%mech = DataController.read_CK_demo()
%[header,data]=DataController.read_scn_file('Samples/CH82.scn')



sprintf('Mechanism is %s, Datafile is %s',mechanism,datafile)

%load the mechanism

col82mec=DataController.read_mechanism_demo();

%%Kicks off a fitting and traces the main steps
[header,data] = DataController.read_scn_file(datafile);
resolvedData = RecordingManipulator.imposeResolution(data,0.1);
[open shut] = RecordingManipulator.getPeriods(resolvedData);
bursts = RecordingManipulator.getBursts(resolvedData,4);
%%I/O. Read the mechanism and the timeseries



%% prepare guesses
initial = col82mec.getRates();

%theta is a list of unconstrained rates
theta = col82mec.getUnconstrainedRates();


%% run the maximum likelihood