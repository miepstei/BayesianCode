dc=DataController();
mecs=dc.list_mechanisms('~/Dropbox/Academic/PhD/Code/bayesiancode/trunk/MarkovModel/Samples/demomec.mec');
mec2=dc.load_mechanism('~/Dropbox/Academic/PhD/Code/bayesiancode/trunk/MarkovModel/Samples/demomec.mec',mecs.mec_struct(2));

%apply concentration to dependent rates
%mec2=mec2.refreshRates(0.00000001);
%mec=dc.read_mechanism_demo();
datasim=generate(mec2,900,0.00000001);
%resolved=RecordingManipulator.imposeResolution(datasim,0.0025);
test_scn='~/Dropbox/Academic/PhD/Code/bayesiancode/trunk/MarkovModel/samples/test.scn';

handle=fopen(test_scn,'w','n','UTF-8');
dc.write_scn_file(handle,datasim);
