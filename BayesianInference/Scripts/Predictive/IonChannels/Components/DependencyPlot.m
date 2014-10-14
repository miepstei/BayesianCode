function dependency = DependencyPlot(qm,kA,kF,tres,t1,t2,dcpoptions)
    %bivariate distribution
    dependency = zeros(length(t1),length(t2));
    phiA = dcpOccupancies(qm,kA,tres,1,dcpoptions);
    phiF  = dcpOccupancies(qm,kA,tres,0,dcpoptions);
    for i=1:length(t1)
        for j=1:length(t2)
            openMissedEventsG = dcpMissedEventsGXYt(qm,kA,t1(i),tres,1,dcpoptions);
            shutMissedEventsG = dcpMissedEventsGXYt(qm,kA,t2(j),tres,0,dcpoptions);
            dependency(i,j) = phiA * openMissedEventsG * shutMissedEventsG * ones(kA,1);
            uniO = phiA * openMissedEventsG * ones(kF,1);
            uniC = phiF'* shutMissedEventsG * ones(kA,1);
            dependency(i,j) = (dependency(i,j) -(uniO * uniC)) / (uniO * uniC);
        end
    end 
end