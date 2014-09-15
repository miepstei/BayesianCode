function ESSoutput  = AverageESS( folder, experiment,lags )
%UNTITLED Calculates the average ESS statistics from a set of experiments
%   INPUT:  folder - filepath of replicates
%           experiment - the experiment over which to calculate the summary statistics
%   OUTPUT: array of average/sd for ESS times per variable

    filePattern = fullfile(strcat(getenv('P_HOME'),folder), strcat(experiment,'*.mat'));
    experimentFiles   = dir(filePattern);
    fileNo=size(experimentFiles,1);
    
    if fileNo > 0
        %process the files
        
        %load the first file to get the numbers of params for ESS
        
        baseFileName = experimentFiles(1).name;
        fullFileName = fullfile(strcat(getenv('P_HOME'),folder), baseFileName);
        fprintf('Now reading %s\n', fullFileName);
        experiment = load(fullFileName);
        ESSraw = zeros(fileNo,size(experiment.samples.params,2));
        ESSsample = zeros(fileNo,size(experiment.samples.params,2));
        ESSmin = zeros(fileNo,size(experiment.samples.params,2));
        
        for i=1:fileNo
            baseFileName = experimentFiles(i).name;
            fullFileName = fullfile(strcat(getenv('P_HOME'),folder), baseFileName);            
            fprintf('Now reading %s\n', fullFileName);
            experiment = load(fullFileName);
            [raw,~,persample,perminute]=CalculateESS(experiment.samples,experiment.SamplerParams,lags);
            ESSraw(i,:) = raw;
            ESSsample(i,:) = persample;
            ESSmin(i,:) = perminute;
        end
        ESSoutput.meanRaw=mean(ESSraw);
        ESSoutput.sdRaw=std(ESSraw);      
        ESSoutput.meanESSsample=mean(ESSsample);
        ESSoutput.sdESSsample=std(ESSsample);
        ESSoutput.meanESSminute=mean(ESSmin);
        ESSoutput.sdESSminute=std(ESSmin);
    else
       error('No files to process, check folder and experiment number') 
    end

end

