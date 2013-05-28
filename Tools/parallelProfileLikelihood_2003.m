%('Samples/Simulations/1985/test_1.scn','Tools/Mechanisms/model_params_CS 1985_2.mat',100,1)
function parallelProfileLikelihood_2003(points,outfile,datafile,mechfile)

    parameter_keys=[1,2,3,4,5,6,11,13,14]; %keys for 1985 model

    param_no=length(parameter_keys);
    profiles=zeros(param_no,points,param_no);
    profile_likelihoods=zeros(param_no,points);

    min=[500,20000,2000,10,20000,50,500,5000,200000000];
    max=[4000,80000,10000,200,100000,500,3000,15000,600000000];


    parfor i=1:length(parameter_keys)
        [a,b]=profileLikelihood(datafile,mechfile,points,parameter_keys(i),min(i),max(i));
        profiles(:,:,i)=a;
        profile_likelihoods(i,:) = b;
    end

    save(outfile, 'profiles','profile_likelihoods');

end

