function gen_scn_file(outname,mec_file,mec_num,constraints,conc)
    dc=DataController();
    mecs=dc.list_mechanisms(mec_file);%'Testing/TestData/demomec.mec');
    %constraints=containers.Map('KeyType', 'int32','ValueType','any');
    mec2=dc.create_mechanism('Testing/TestData/demomec.mec',mecs.mec_struct(mec_num),constraints);

    %apply concentration to dependent rates
    %mec2=mec2.refreshRates(0.00000001);
    %mec=dc.read_mechanism_demo();
    datasim=generate(mec2,1000*60*15,conc,20000);
    %resolved=RecordingManipulator.imposeResolution(datasim,0.0025);

    handle=fopen(outname,'w','n','UTF-8');
    dc.write_scn_file(handle,datasim);
