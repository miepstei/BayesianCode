function fig = generate_bivariate_plot(experiment,data,datatype,rows,cols)
    MSEC=1000;
    fig=figure('Visible','off');
    
    for conc_no=1:length(experiment.data.concs)
        tres=experiment.data.tres(conc_no);
        conc=experiment.data.concs(conc_no);   
        if strcmp(datatype , 'Experimental')
            resolvedData = data{conc_no};
            %we have experimental data eq
        elseif strcmp(datatype, 'Synthetic')
            [~,plotdata]=DataController.read_scn_file(data{conc_no});
            plotdata.intervals=plotdata.intervals/MSEC; 
            resolvedData = RecordingManipulator.imposeResolution(plotdata,tres);
        end
        [o, s] = RecordingManipulator.getPeriods(resolvedData);
        plotdata=[ o.intervals' s.intervals'];        
        plotdata=plotdata*MSEC;
        logMsData=log10(plotdata);
        subplot(rows,cols,conc_no)
        min_axis = [-2 , -2];
        max_axis = [2 , 6];
        [~,density,open_axis,shut_axis] = kde2d(logMsData, 2^8,min_axis,max_axis);
        surf(open_axis,shut_axis,density,'LineStyle','none'), view([50,50])
        xlim([min_axis(1) max_axis(1)])
        ylim([min_axis(2) max_axis(2)])
        zlim([0 1])
        title(strcat(num2str(conc),' M'))
        
        if conc_no == length(experiment.data.concs)
            %just want the axes to appear on the last plot
            ylabel('Shut Time, ms')
            xlabel('Open Time, ms')
        end

    end
end