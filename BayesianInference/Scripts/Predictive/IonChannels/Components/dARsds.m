function deriv =  dARsds (qm,tres,kA,kF)

    Q_AA = qm(1:kA,1:kA);
    Q_AF = qm(1:kA,kA+1:kA+kF);
    Q_FA = qm(kA+1:kA+kF,1:kA);
    Q_FF = qm(kA+1:kA+kF,kA+1:kA+kF);
    eFFt = expm(Q_FF*tres);

    %dAdS
    S_FF = eye(kF,kF) - eFFt; %s=0

    %P(move to F | start in A) %s=0
    G_AF = (-Q_AA^-1)*Q_AF;

    %P(move to A | start in F) %s=0
    G_FA = (-Q_FF^-1)*Q_FA;

    Q1 = tres * G_AF * (eFFt * G_FA);
    Q2 = G_AF * (S_FF * (Q_FF^-1 * G_FA));
    Q3 = ((-Q_AA^-1*G_AF)*S_FF)*G_FA;
    Q4 = Q1-Q2+Q3;

    VA = eye(kA,kA) - ((G_AF*S_FF)*G_FA);
    Q5 = Q_AA^(-1)-(Q4*VA^-1);
    deriv = ((VA^-1) * Q5) * Q_AA^-1;
    
%       VA = eye(kA,kA) - (G_AF * S_FF * G_FA);
% 
%       ddSVAs = -(Q_AA^-1) * G_AF * S_FF * G_FA;
%       ddSVAs = ddSVAs - (G_AF * S_FF * (Q_FF^-1) * G_FA);
%       ddSVAs = ddSVAs - (tres * G_AF * eFFt * G_FA);
%       
%       deriv = VA^(-1) * (Q_AA^-2);
%       deriv = deriv -  VA^(-1) * ddSVAs * VA^(-1) * (Q_AA^-1);

end