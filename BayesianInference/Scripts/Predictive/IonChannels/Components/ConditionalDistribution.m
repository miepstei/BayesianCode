function conditionalDistribution = ConditionalDistribution(qm,kA,kF,tres,t_hi,t_lo,t,isopen,dcpoptions)

    %conditional open/closed distribution based on previous closed/open shuttings in a range
    Q_AF = qm(1:kA,kA+1:end);
    Q_AA = qm(1:kA,1:kA);
    Q_FF = qm(kA+1:end,kA+1:end);
    Q_FA = qm(kA+1:end,1:kA);
    
    

    conditionalDistribution = zeros(length(t),1);
    
    if isopen
        phi = dcpOccupancies(qm,kA,tres,0,dcpoptions);
        KuHi = CumulativeSurvivor(t_hi-tres,tres,qm,kA,0,dcpoptions);
        KuLo = CumulativeSurvivor(t_lo-tres,tres,qm,kA,0,dcpoptions);
    
        CumHi = CumulativeSurvivor(t_hi-tres,tres,qm,kA,0,dcpoptions);
        CumLo = CumulativeSurvivor(t_lo-tres,tres,qm,kA,0,dcpoptions);
    
        cumulativeHi = phi' * CumHi * Q_FA * expm(Q_AA*tres) * ones(kA,1);
        cumulativeLo = phi' * CumLo * Q_FA * expm(Q_AA*tres) * ones(kA,1);
        for i=1:length(t)
            conditionalDistribution(i) = phi' * (KuHi - KuLo) * Q_FA * expm(Q_AA*tres) * dcpMissedEventsGXYt(qm,kA,t(i),tres,1,dcpoptions)* ones(kF,1);
            conditionalDistribution(i) = t(i)*conditionalDistribution(i)/(cumulativeHi-cumulativeLo);
        end
    else
        phi = dcpOccupancies(qm,kA,tres,1,dcpoptions);
        KuHi = CumulativeSurvivor(t_hi-tres,tres,qm,kA,1,dcpoptions);
        KuLo = CumulativeSurvivor(t_lo-tres,tres,qm,kA,1,dcpoptions);
    
        CumHi = CumulativeSurvivor(t_hi-tres,tres,qm,kA,1,dcpoptions);
        CumLo = CumulativeSurvivor(t_lo-tres,tres,qm,kA,1,dcpoptions);        
        
        cumulativeHi = phi * CumHi * Q_AF * expm(Q_FF*tres) * ones(kF,1);
        cumulativeLo = phi * CumLo * Q_AF * expm(Q_FF*tres) * ones(kF,1);
        for i=1:length(t)
            conditionalDistribution(i) = phi * (KuHi - KuLo) * Q_AF * expm(Q_FF*tres) * dcpMissedEventsGXYt(qm,kA,t(i),tres,0,dcpoptions)* ones(kA,1);
            conditionalDistribution(i) = t(i)*conditionalDistribution(i)/(cumulativeHi-cumulativeLo);
        end        
        
    end
end