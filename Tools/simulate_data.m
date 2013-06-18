function simulate_data(simFile,mechParams,intervals)
    %2003 generative params
    load(mechParams)
    generativeMec=ModelSetup(mechParams);%'/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_2.mat');

    %generate  intervals
    datasim=generate(generativeMec,10000*60*15,concentration,intervals);
    handle=fopen(simFile,'w','n','UTF-8');
    DataController.write_scn_file(handle,datasim);
end
