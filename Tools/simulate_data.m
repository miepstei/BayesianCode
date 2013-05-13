function simulate_data(simFile,mechParams,intervals)
    %2003 generative params
    test_params=Test_Setup(mechParams);%'/Volumes/Users/Dropbox/Academic/PhD/Code/git-repo/Testing/Results/matlab_params_CS 1985_2.mat');
    generativeMec=test_params.mechanism;
    clear test_params

    %generate  intervals
    datasim=generate(generativeMec,1000*60*15,3e-08,intervals);
    handle=fopen(simFile,'w','n','UTF-8');
    DataController.write_scn_file(handle,datasim);
end