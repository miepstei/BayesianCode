function unconditionalIdealDistribution = UnconditionalIdealPDF(qm,kA,kF,tres,t,isopen,dcpoptions)

    %unconditional distribution
    unconditionalIdealDistribution = zeros(length(t),1);
    if isopen
        phiA = dcpOccupancies(qm,kA,tres,1,dcpoptions);
        Q_AA = qm(1:kA,1:kA);
        Q_AF = qm(1:kA,1+kA:end);
        
        
        for i=1:length(t)
            unconditionalIdealDistribution(i) = t(i) * phiA * expm(Q_AA*t(i))* Q_AF * ones(kF,1);
        end
        
    else
        phiF = dcpOccupancies(qm,kA,tres,0,dcpoptions);
        Q_FF = qm(kA+1:end,kA+1:end);
        Q_FA = qm(kA+1:end,1:kA);

        for i=1:length(t)
            unconditionalIdealDistribution(i) = t(i) * phiF' * expm(Q_FF*t(i)) * Q_FA * ones(kA,1);
        end         
    end
end