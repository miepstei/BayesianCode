function cmean = ContinuousConditionalMean( qm,kA,kF,tres,t,isopen,dcpoptions )
%UNTITLED3 Mean of the next period given a preceeding period of shut/open
%time t

    Q_AF = qm(1:kA,kA+1:end);
    Q_AA = qm(1:kA,1:kA);
    Q_FF = qm(kA+1:end,kA+1:end);
    Q_FA = qm(kA+1:end,1:kA);
    
    phiF = dcpOccupancies(qm,kA,tres,0,dcpoptions);
    phiA = dcpOccupancies(qm,kA,tres,1,dcpoptions);

    
    if isopen
        cmean =  (phiF' * dcpMissedEventsGXYt(qm,kA,t,tres,0,dcpoptions) * dARsds(qm,tres,kA,kF) * Q_AF * expm(Q_FF*tres) * ones(kF,1));
        cmean =  cmean / (phiF' * dcpMissedEventsGXYt(qm,kA,t,tres,0,dcpoptions) * ones(kA,1));
        %cmean = cmean + tres;
    else
        error('not implemented correctly')
        cmean = 0; tres + phiF * dcpMissedEventsGXYt(qm,kA,t,tres,1,dcpoptions) * dARsds(qm,tres,kA,kF) * Q_FA * expm(Q_AA*tres) * ones(kA,1);
    end
end

