function fig = generate_conditional_plot(experiment,data,datatype,posterior_samples,isopen,rows,cols,kA,kF,conditional_range,dcpoptions)
    MSEC=1000; %scale factor for seconds -> milliseconds
    fig=figure('Visible','on');

    %determine a consistent scale length for all the plots
    Q=experiment.model.generateQ(experiment.startParams,experiment.data.concs(1));
    max_root = max(-1./dcpFindRoots(Q,experiment.model.kA,experiment.data.tres(1),isopen,dcpoptions));
    t = logspace(log10(0.00001),log10(max_root*20),512)';
    
    conc_number = length(experiment.data.concs);
    
    for conc_no=1:conc_number
        tres=experiment.data.tres(conc_no);
        conc=experiment.data.concs(conc_no);        
        if strcmp(datatype , 'Synthetic')
            [~,sequence]=DataController.read_scn_file(data{conc_no});
            sequence.intervals=sequence.intervals/MSEC;

            resolvedData = RecordingManipulator.imposeResolution(sequence,tres);
        elseif strcmp(datatype, 'Experimental')
            resolvedData = data{conc_no};
        else
            error('Datafiles not recognised!')
        end
        
        subplot(rows,cols,conc_no)
        conditional_open = RecordingManipulator.getSuceedingPeriodsWithRange(resolvedData,1,conditional_range);
        [buckets,frequency,dx] =  Histogram(conditional_open,tres);
        semilogx(buckets*MSEC,frequency./(length(conditional_open)*log10(dx)*2.30259),'LineWidth',2);
        title(strcat('Concentration = ', num2str(conc),' M'),'FontSize',16)
        hold on;  
        
        for i=1:size(posterior_samples,1)
            params = posterior_samples(i,:);
            Q=experiment.model.generateQ(params',conc);
            semilogx(t*MSEC,ConditionalDistribution(Q,kA,kF,tres,conditional_range(1),conditional_range(2),t,isopen,dcpoptions)); 
            hold on; 
            semilogx(t*MSEC,UnconditionalExactPDF(Q,kA,kF,tres,t,isopen,dcpoptions),'r'); 
        end        
        
        if conc_no == conc_number
            xlabel('log10(msec)')
            ylabel('density')
        end
        
        hold off
    end
end
