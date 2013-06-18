function mechanism = ModelSetup(paramsFile)
	%this really should be defined in an external XML/YAML file of some description passed to the DataController,
	%but instead is a hybrid approach of mec and XML. In reality the XML has to "know" about the 
	%structure of the mechanism (i.e. the number of rates) of the mec file, which somewhat defeats the purpose to abstracting away the
	%mechanism to the XML file format.
	
	%It does, however, allow us to apply starting values to parameters outside of matlab code, and 
	%constraints, to apply them to the mechanism. Mec files do not specify constraints, these are in the .ini files.
	%These are not currently parsed in the Matlab code
	
	load(paramsFile);

	if strcmp(model,'CH82')
		%this should really run from a specified mec file...
		mechanism = DataController.read_mechanism_demo();
		update_constraints=0;
		mechanism.setRate(1,p1,update_constraints);
		mechanism.setRate(2,p2,update_constraints);
		mechanism.setRate(3,p3,update_constraints);
		mechanism.setRate(4,p4,update_constraints);
		mechanism.setRate(5,p5,update_constraints);
		mechanism.setRate(6,p6,update_constraints);
		mechanism.setRate(7,p7,update_constraints);
		mechanism.setRate(8,p8,update_constraints);
		mechanism.setRate(9,p9,update_constraints);
		mechanism.setRate(10,p10,update_constraints);
	elseif strcmp(model,'CS 1985')
		mecs=DataController.list_mechanisms(mechanismfilepath);
	
		%set constraints here
		constraints=containers.Map('KeyType', 'int32','ValueType','any');
		constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',11,'args',1);
		constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',8,'args',1);%FIXED!
		constraints(9)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',13,'args',1); 
		constraints(10)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',14,'args',1);
		constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);
	
		mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints);
		update_constraints=0;
		mechanism.setRate(1,p1,update_constraints);
		mechanism.setRate(2,p2,update_constraints);
		mechanism.setRate(3,p3,update_constraints);
		mechanism.setRate(4,p4,update_constraints);
		mechanism.setRate(5,p5,update_constraints);
		mechanism.setRate(6,p6,update_constraints);
		mechanism.setRate(7,p7,update_constraints);
		mechanism.setRate(8,p8,update_constraints);
		mechanism.setRate(9,p9,update_constraints);
		mechanism.setRate(10,p10,update_constraints);
		mechanism.setRate(11,p11,update_constraints);
		mechanism.setRate(12,p12,update_constraints);
		mechanism.setRate(13,p13,update_constraints);
		mechanism.setRate(14,p14,update_constraints);

    elseif strcmp(model,'CS 1985 k_+2a unconstrained')

        mecs=DataController.list_mechanisms(mechanismfilepath);
        
        %set constraints here
        constraints=containers.Map('KeyType', 'int32','ValueType','any');
        constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',11,'args',1);
        constraints(9)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',13,'args',1);
        constraints(10)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',14,'args',1);
        constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);


        mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints);
        update_constraints=0;

        mechanism.setRate(1,p1,update_constraints);
        mechanism.setRate(2,p2,update_constraints);
        mechanism.setRate(3,p3,update_constraints);
        mechanism.setRate(4,p4,update_constraints);
        mechanism.setRate(5,p5,update_constraints);
        mechanism.setRate(6,p6,update_constraints);
        mechanism.setRate(7,p7,update_constraints);
        mechanism.setRate(8,p8,update_constraints);
        mechanism.setRate(9,p9,update_constraints);
        mechanism.setRate(10,p10,update_constraints);
        mechanism.setRate(11,p11,update_constraints);
        mechanism.setRate(12,p12,update_constraints);
        mechanism.setRate(13,p13,update_constraints);
        mechanism.setRate(14,p14,update_constraints);

    elseif strcmp(model,'CS 1985 unconstrained')
        mecs=DataController.list_mechanisms(mechanismfilepath);
        
        %set constraints here
        constraints=containers.Map('KeyType', 'int32','ValueType','any');
        constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',8,'args',1);%FIXED in order to get some fit!
        constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);
        
        mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints);
        update_constraints=0;
        
		mechanism.setRate(1,p1,update_constraints);
		mechanism.setRate(2,p2,update_constraints);
		mechanism.setRate(3,p3,update_constraints);
		mechanism.setRate(4,p4,update_constraints);
		mechanism.setRate(5,p5,update_constraints);
		mechanism.setRate(6,p6,update_constraints);
		mechanism.setRate(7,p7,update_constraints);
		mechanism.setRate(8,p8,update_constraints);
		mechanism.setRate(9,p9,update_constraints);
		mechanism.setRate(10,p10,update_constraints);
		mechanism.setRate(11,p11,update_constraints);
		mechanism.setRate(12,p12,update_constraints);
		mechanism.setRate(13,p13,update_constraints);
		mechanism.setRate(14,p14,update_constraints);        
        
	else
		fprintf('Model %s is currently undefined in this context, ignoring model construction\n',model)
		mechanism=Mechanism.empty(1,0);
	end

end