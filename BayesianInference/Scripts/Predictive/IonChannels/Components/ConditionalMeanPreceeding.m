function conditionalMean = ConditionalMeanPreceeding(qm,kA,kF,tres,t_hi,t_lo,dcpoptions)
    %calculates the mean of a conditional distribution with a specified
    %preceeding shut or open interval range
    
    phiF = dcpOccupancies(qm,kA,tres,0,dcpoptions);
    Q_AF = qm(1:kA,kA+1:end);
    Q_AA = qm(1:kA,1:kA);
    Q_FF = qm(kA+1:end,kA+1:end);
    Q_FA = qm(kA+1:end,1:kA);

    
    cumulativeHi = CumulativeUnconditional(qm,kA,kF,tres,t_hi,0,dcpoptions); 
    cumulativeLo = CumulativeUnconditional(qm,kA,kF,tres,t_lo,0,dcpoptions);    
    
    KuHi = CumulativeSurvivorVM(t_hi-tres,tres,qm,kA,0,dcpoptions);
    KuLo = CumulativeSurvivorVM(t_lo-tres,tres,qm,kA,0,dcpoptions);

    conditionalMean =  (phiF' * (KuHi - KuLo) *Q_FA * (expm(Q_AA*tres) * ones(kA,1))/(cumulativeHi-cumulativeLo));
    conditionalMean = tres + conditionalMean;

end