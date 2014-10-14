function unconditionalDistribution = UnconditionalExactCDF(qm,kA,kF,tres,t,isopen,dcpoptions)

    %unconditional distribution
    
    if isopen
        phiA = dcpOccupancies(qm,kA,tres,1,dcpoptions);
        Q_FF = qm(kA+1:end,kA+1:end);
        Q_AF = qm(1:kA,1+kA:end);
        unconditionalDistribution = zeros(length(t),1);
        for i=1:length(t)
            Ku = CumulativeSurvivor(t(i)-tres,tres,qm,kA,1,dcpoptions);
            unconditionalDistribution(i) = phiA * Ku * Q_AF * expm(Q_FF*tres) * ones(kF,1);
        end
        
    else
        phiF = dcpOccupancies(qm,kA,tres,0,dcpoptions);
        unconditionalDistribution = zeros(length(t),1);
        Q_AA = qm(1:kA,1:kA);
        Q_FA = qm(1+kA:end,1:kA);
        for i=1:length(t)
            Ku = CumulativeSurvivor(t(i)-tres,tres,qm,kA,0,dcpoptions);
            unconditionalDistribution(i) = phiF' * Ku * Q_FA * expm(Q_AA*tres) * ones(kA,1);
        end         
    end
end