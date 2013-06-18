function parallelProfileLikelihood_2003(points,parameter_keys,min,max,outfile,datafile,mechfile)
      
    param_no=length(parameter_keys);
    profiles=zeros(param_no,points,param_no);
    profile_likelihoods=zeros(param_no,points);

    parfor i=1:param_no
        fprintf('loop %i key %i min %f max %f',i, parameter_keys(i),min(i),max(i))
        [a,b]=profileLikelihood(datafile,mechfile,points,parameter_keys(i),min(i),max(i));
        profiles(:,:,i)=a;
        profile_likelihoods(i,:) = b;
    end

    save(outfile, 'profiles','profile_likelihoods','points','parameter_keys','min','max','outfile','datafile','mechfile');

end

