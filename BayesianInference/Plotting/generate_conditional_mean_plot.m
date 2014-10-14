function fig = generate_conditional_mean_plot(experiment,data,datatype,posterior_samples,isopen,rows,cols,kA,kF,conditional_ranges,dcpoptions)
    fig=figure('Visible','off');
    
    conc_number = length(experiment.data.concs);
    no_of_samples = size(posterior_samples,1);
    
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
        
        subplot(rows,cols,conc_no);

        conditional_mean_open = zeros(size(conditional_ranges,1),no_of_samples);
        conditional_mean_close = zeros(size(conditional_ranges,1),no_of_samples);
        empirical_mean_open = zeros(size(conditional_ranges,1),1);
        empirical_mean_close = zeros(size(conditional_ranges,1),1);
        empirical_std_open = zeros(size(conditional_ranges,1),1);
        empirical_n_open = zeros(size(conditional_ranges,1),1);
        
        for i=1:size(conditional_ranges,1)
            for j=1:size(posterior_samples,1)
                params = posterior_samples(j,:);
                Q=experiment.model.generateQ(params',conc);
                conditional_mean_open(i,j) = ConditionalMean(Q,kA,kF,tres,conditional_ranges(i,2),conditional_ranges(i,1),dcpoptions)*1000;
                conditional_mean_close(i,j) = ConditionalMeanPreceeding(Q,kA,kF,tres,conditional_ranges(i,2),conditional_ranges(i,1),dcpoptions)*1000;
            end    
            succeeding_openings = RecordingManipulator.getSuceedingPeriodsWithRange(resolvedData,isopen,conditional_ranges(i,:));
            
            empirical_mean_open(i) = mean(succeeding_openings);
            empirical_mean_close(i) =  mean(RecordingManipulator.getPeriodsWithRange(resolvedData,~isopen,conditional_ranges(i,:)));
            empirical_std_open(i) = std(succeeding_openings);
            empirical_n_open(i) = length(succeeding_openings); 
        end

        errorbar(empirical_mean_close*1000,empirical_mean_open*1000,empirical_std_open*1000./sqrt(empirical_n_open))
        hold on;
        c = linspace(1,10,length(conditional_ranges));
        for j=1:size(posterior_samples,1)
            scatter(conditional_mean_close(:,j),conditional_mean_open(:,j),[],c)
        end
        hold off
        set(gca,'XScale','log');

    end
end