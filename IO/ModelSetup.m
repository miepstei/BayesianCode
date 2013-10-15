function mechanism = ModelSetup(paramsFile,refactorMechanism)
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
		mechanism = DataController.read_mechanism_demo(refactorMechanism);
        
        %create parameter map
        parameters = containers.Map([1 2 3 4 5 9],[p1 p2 p3 p4 p5 p9]);
        mechanism.setParameters(parameters);
        if refactorMechanism
            mechanism.updateRates();
        end

	elseif strcmp(model,'CS 1985')
		mecs=DataController.list_mechanisms(mechanismfilepath);
	
		%set constraints here
		constraints=containers.Map('KeyType', 'int32','ValueType','any');
		constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',11,'args',1);
		constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',8,'args',1);%FIXED!
		constraints(9)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',13,'args',1); 
		constraints(10)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',14,'args',1);
		constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);
	
		mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints,refactorMechanism);
        %mechanism.cycles(1).mr_constrainted_rate=12;

        %create parameter map
        rates = containers.Map([1 2 3 4 5 6 7 8 9 10 11 12 13 14],[p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14]);        
        mechanism.setRates(rates);
        if refactorMechanism
            mechanism.updateRates();
        end

    elseif strcmp(model,'CS 1985 k_+2a unconstrained')

        mecs=DataController.list_mechanisms(mechanismfilepath);
        
        %set constraints here
        constraints=containers.Map('KeyType', 'int32','ValueType','any');
        constraints(7)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',11,'args',1);
        constraints(9)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',13,'args',1);
        constraints(10)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',14,'args',1);
        constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);

        mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints,refactorMechanism);
        %mechanism.cycles(1).mr_constrainted_rate=12;
        
        %create parameter map
        rates = containers.Map([1 2 3 4 5 6 7 8 9 10 11 12 13 14],[p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14]);        
        mechanism.setRates(rates);
        if refactorMechanism
            mechanism.updateRates();
        end

    elseif strcmp(model,'CS 1985 unconstrained')
        mecs=DataController.list_mechanisms(mechanismfilepath);
        
        %set constraints here
        constraints=containers.Map('KeyType', 'int32','ValueType','any');
        constraints(8)=struct('type','dependent','function',@(rate,factor)rate*factor,'rate_id',8,'args',1);%FIXED in order to get some fit!
        constraints(12)=struct('type','mr','function',@(rate,factor)rate,'rate_id',12,'cycle_no',1);
        
        mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(2),constraints,refactorMechanism);
        %mechanism.cycles(1).mr_constrainted_rate=12;
        
        %create parameter map
        rates = containers.Map([1 2 3 4 5 6 7 8 9 10 11 12 13 14],[p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14]);        
        mechanism.setRates(rates);
        if refactorMechanism
            mechanism.updateRates();
        end
    elseif strcmp(model,'CS 1985 desensitised')
        mecs=DataController.list_mechanisms(mechanismfilepath);
        %set constraints here
        constraints=containers.Map('KeyType', 'int32','ValueType','any');
        %constraints(16)=struct('type','mr','function',@(rate,factor)rate,'rate_id',16,'cycle_no',1); 
        
        mechanism=DataController.create_mechanism(mechanismfilepath,mecs.mec_struct(1),constraints,refactorMechanism);
        
        %create parameter map
        rates = containers.Map([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16],[p1 p2 p3 p4 p5 p6 p7 p8 p9 p10 p11 p12 p13 p14 p15 p16]);        
        mechanism.setRates(rates);
        if refactorMechanism
            mechanism.updateRates();
        end
        
	else
		fprintf('Model %s is currently undefined in this context, ignoring model construction\n',model)
		mechanism=Mechanism.empty(1,0);
	end

end