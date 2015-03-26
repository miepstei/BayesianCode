function fig = generate_unconditional_plot(experiment,data,datatype,posterior_samples,isopen,rows,cols,kA,kF,dcpoptions)
    MSEC=1000;
    fig=figure('Visible','on');
    
    
    %determine a consistent scale length for all the plots
    Q=experiment.model.generateQ(experiment.startParams,experiment.data.concs(1));
    max_root = max(-1./dcpFindRoots(Q,experiment.model.kA,experiment.data.tres(1),isopen,dcpoptions));
    t = logspace(log10(0.00001),log10(max_root*20),512)';
    
    conc_number = length(experiment.data.concs);
    
    for conc_no=1:conc_number
        tres=experiment.data.tres(conc_no);
        conc=experiment.data.concs(conc_no);        
        
        if strcmp(datatype , 'Experimental')
            resolvedData = data{conc_no};
            %we have experimental data equivalent to the function call RecordingManipulator.imposeResolution(data,tres);            
            
        elseif strcmp(datatype, 'Synthetic')
            %use scn files
            [~,sequence]=DataController.read_scn_file(data{conc_no});
            sequence.intervals=sequence.intervals/1000;
            resolvedData = RecordingManipulator.imposeResolution(sequence,tres);
        else
            error('Datafiles not recognised!')
        end
        
        if isopen
            [intervals, ~] = RecordingManipulator.getPeriods(resolvedData);
        else
            [~, intervals] = RecordingManipulator.getPeriods(resolvedData);
        end
        
        subplot(rows,cols,conc_no)        
        [buckets,frequency,dx] =  Histogram(intervals.intervals,tres);
        semilogx(buckets*MSEC,frequency./(length(intervals.intervals)*log10(dx)*2.30259),'LineWidth',2);
        hold on;  
        title(strcat('Concentration = ', num2str(conc),' M'),'FontSize',16)

        for i=1:size(posterior_samples,1)
            params = posterior_samples(i,:);
            Q=experiment.model.generateQ(params',conc);
            pdf =  UnconditionalExactPDF(Q,kA,kF,tres,t,isopen,dcpoptions);
            semilogx(t*MSEC,pdf,'r','LineWidth',1);
            pdf_i = UnconditionalIdealPDF(Q,kA,kF,tres,t,isopen,dcpoptions);
            semilogx(t*MSEC,pdf_i,'g','LineWidth',1);
        end        
        
        if conc_no == conc_number
            xlabel('log10(msec)')
            ylabel('density')
        end
        
        hold off
    end
end
