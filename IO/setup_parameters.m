function param_struct = setup_parameters(tres,tcrit,concs,use_chs,debug_on,fit_logspace) 
    %Function returns a struct of all the experimental parameters, data and
    %model
    
    %INPUTS:tres - scalar resolution time of recordings (seconds)
    %       tcrit - scalar time for separating bursts (seconds)
    %       concs - array of concentrations to apply to data
    %       use_chs - array of flags to use CHS vectors in fitting or not
    %       fit_logspace - to fit models in logspace
    
    %RETURNS: param_strut - a struct containg the above
    
    param_struct.tres=tres;
    param_struct.tcrit=tcrit;
    param_struct.concs=concs;
    param_struct.use_chs=use_chs;
    param_struct.debug_on=debug_on;
    param_struct.fit_logspace=fit_logspace;
    param_struct.newMech=1;

end