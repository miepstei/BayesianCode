function cumulativeUnconditional = CumulativeUnconditional(qm,kA,kF,tres,t,isopen,dcpoptions)
    %calculates the cumulative distribution of the missed events pdf
    
    if ~isopen
        phiF = dcpOccupancies(qm,kA,tres,isopen,dcpoptions);
        Q_AA = qm(1:kA,1:kA);
        Q_FA = qm(kA+1:end,1:kA);

        Ku = CumulativeSurvivor(t-tres,tres,qm,kA,isopen,dcpoptions);
        cumulativeUnconditional = phiF' * Ku * Q_FA * expm(Q_AA*tres) * ones(kA,1);
    else
        phiA = dcpOccupancies(qm,kA,tres,isopen,dcpoptions);
        Q_AF = qm(1:kA,kA+1:end);
        Q_FF = qm(kA+1:end,kA+1:end);

        Ku = CumulativeSurvivor(t-tres,tres,qm,kA,isopen,dcpoptions);
        cumulativeUnconditional = phiA * Ku * Q_AF * expm(Q_FF*tres) * ones(kF,1);        
        
    end



end