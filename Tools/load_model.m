function mechanism = load_model(modelfile)
    %Generates a mechanism from a parameter file and sets rates to overrife
    %defaults
    
    %INPUTS:    modelfile - a file path containing model parameters
                
    %OUTPUTS:   mechanism - an object of class MechanismUpdate with rates
    %           and constraints applied
    
    mechanism=ModelSetup(modelfile,1);
    mechanism.updateRates();
    

end