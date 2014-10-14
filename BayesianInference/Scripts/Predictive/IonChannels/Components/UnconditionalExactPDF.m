function unconditionalDistribution = UnconditionalExactPDF(qm,kA,kF,tres,t,isopen,dcpoptions)

    %unconditional distribution
    
    if isopen
        phiA = dcpOccupancies(qm,kA,tres,1,dcpoptions);

        unconditionalDistribution = zeros(length(t),1);
        for i=1:length(t)
            unconditionalDistribution(i) = t(i) * phiA * dcpMissedEventsGXYt(qm,kA,t(i),tres,1,dcpoptions)* ones(kF,1);
        end
        
    else
        phiF = dcpOccupancies(qm,kA,tres,0,dcpoptions);

        unconditionalDistribution = zeros(length(t),1);
        for i=1:length(t)
            unconditionalDistribution(i) = t(i) * phiF' * dcpMissedEventsGXYt(qm,kA,t(i),tres,0,dcpoptions)* ones(kA,1);
        end         
    end
end