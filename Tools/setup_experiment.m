function experiment = setup_experiment(tres,tcrit,concs,use_chs,debug_on,fit_logspace,datafiles,modelfile)
    %sets up and experiment structure with the data, model and parameters

    %INPUTS:
            %tres - an array of resolution times, one per dataset
            %tcrit - an array of burst separation times, one per dataset
            %concs - an array of concentrations, one per dataset
            %use_chs - array of flags as to whether to use chs vectors in
                        %fitting
            %debug_on - scalar flag - whether to have simplex debug output
            %fit_logspace - scalar flag - whether to fit model in log space
            %datafiles - a cell array of data file paths to fit the model
            %modelfile - a file containing the model representation

    %OUTPUT:    experiment: a structure containing data in bursts,
                %experimental params and a model
    
    %error checking  -check we have concs,tres etc. for each dataset
    
    no_concs = length(concs);
    no_tres = length(tres);
    no_chs = length(use_chs);
    no_tcrits = length(tcrit);
    no_datasets = length(datafiles);
    
    if (isequal(no_concs , no_tres , no_chs , no_tcrits , no_datasets))
        [experiment.parameters] = setup_parameters(tres,tcrit,concs,use_chs,debug_on,fit_logspace);
        experiment.model = load_model(modelfile);
        [experiment.data,data_description] = load_data(datafiles,tres,tcrit);
    else
        error('concs, tres, tcrit and chs_vectors need to be applied to all datasets');
    end
    
    experiment.description.model = experiment.model.mechanism_name;
    experiment.description.data = data_description;

end
