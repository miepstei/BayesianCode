function filenames = generateAchData(model,concs,required_transitions)

    %% Generate Acetylcholine data

    %model = SevenState_10Param_AT();
    %concs = [0.0000003,0.000001,0.00001,0.00003];
    %tcrit = [0.0003,0.001,0.007,0.002];
    %tres  = [0.00002,0.00002,0.00002,0.00002];
    %useChs = [1 1 0 0];
    %required_transitions = 10000;
    
    load(strcat(getenv('P_HOME'),'/BayesianInference/Data/SevenStateGuessesAndParams.mat'))
    dc=DataController;
    params=true1(ten_param_keys);  
    filenames=cell(length(concs),1);
    
    savedir = strcat(getenv('P_HOME'), '/BayesianInference/Data/AchGeneration/');
    if ~isequal(exist(savedir, 'dir'),7)
        mkdir(savedir)
    end
    
    
    for set=1:length(concs)
        recording = generate_data(params,model,concs(set),required_transitions);
        [~,tmpname,~]=fileparts(tempname);
        filenames{set} = strcat(getenv('P_HOME'),'/BayesianInference/Data/AchGeneration/', num2str(required_transitions),'_' ,tmpname,'_Synth_Ach_',num2str(concs(set)),'.scn');
        handle = fopen(filenames{set},'w');
        dc.write_scn_file(handle,recording);
    end

end