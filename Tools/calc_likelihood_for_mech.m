function likelihood=calc_likelihood_for_mech(datafile,paramsfile,varargin)

    %INPUTS:
    %   datafile: the .scn file to calculate the likelihood for
    %   paramsfile: the set of parameters and mechanism 
    
    %OUTPUT:
    %   a likelihood with missed events correction

    load(paramsfile);
    dc=DataController();

    [~,test_params.data]=dc.read_scn_file(datafile);
    test_params.data.intervals=test_params.data.intervals/1000;

    test_params.conc=concentration;
    test_params.tres=tres;
    test_params.tcrit=tcrit;

    resolvedData = RecordingManipulator.imposeResolution(test_params.data,test_params.tres);
    bursts = RecordingManipulator.getBursts(resolvedData,test_params.tcrit);
    test_params.bursts=bursts;
    test_params.islogspace=true;
    test_params.debugOn=true;
    test_params.isCHS=true;
    test_params.mechanism=ModelSetup(paramsfile);

    if length(varargin)==2
        if strcmp(varargin{2},'p')
            %optional parameter map has been set so use it
            test_params.mechanism.setParameters(varargin{1});
        else strcmp(varargin{2},'p')
            %we are setting all the rates, presumably to debug a likelihood
            %calculation
            test_params.mechanism.setRates(varargin{1},0);
        end
    end
    
    lik = ExactLikelihood();    
    [open_times,closed_times,withinburst_count,l_openings] = lik.calculate_burst_parameters(bursts);
    lik=lik.setup_likelihood(test_params.mechanism, test_params.conc, test_params.tres,test_params.tcrit, test_params.isCHS);
    likelihood=lik.calculate_likelihood_vectorised(test_params.bursts,open_times,closed_times,withinburst_count,l_openings);
    
end

