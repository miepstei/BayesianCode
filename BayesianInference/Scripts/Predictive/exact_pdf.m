function [ p, open_areas, open_roots ] = exact_pdf(Q,kA,kF,t,tres)

    %load('Data/AchRealData.mat')
    %model = SevenState_10Param_QET();
    %startParams=[  2.12694727e+03   5.22450234e+04   5.95298145e+03   5.67086411e+01 5.61611836e+04   8.89628830e+01   1.00000000e+08   1.52130078e+03 9.46586621e+03   4.14601856e+08]';

    %Q=model.generateQ(startParams,1);
    %load('/Volumes/Users/Dropbox/Academic/PhD/Code/dc-pyps-new/pdftest.mat')

    %kA=model.kA;
    QAA = Q(1:kA,1:kA);
    QAF = Q(1:kA,kF:end);
    QFA = Q(kF:end,1:kA);
    QFF = Q(kF:end,kF:end);

    lik=ExactLikelihood();

    %spectral matrices
    [~, eigsQ, ~] = lik.spectral_expansion(-Q);
    eigsQ=diag(eigsQ);

    %P(move to F | start in A)
    G_AF = (-QAA^-1)*QAF;

    %P(move to A | start in F)
    G_FA = (-QFF^-1)*QFA;

    %expQFF

    expG_FF = expm(QFF*tres);
    expG_AA = expm(QAA*tres);

    %observed P(move to F | start in A)
    eG_AF = (eye(kA,kA) - (G_AF*(eye(kF,kF) - expG_FF)*G_FA))^-1 * G_AF * expG_FF;

    %observed P(move to A | start in F)
    eG_FA = (eye(kF,kF) - (G_FA*(eye(kA,kA) - expG_AA)*G_AF))^-1 * G_FA * expG_AA;

    %inital HJC vector for openings - solve phi*(I-eGAF*eGFA)=0
    I_phiA = eye(kA,kA) - (eG_AF*eG_FA);

    %plus one trick to solve for occupancy
    S=I_phiA;
    S(:,length(S)+1)=1;
    phiA=sum(inv(S*S'),2);

    %survivor function
    % OPEN STATES

    % we need the Z matrix constants for the exact open/shut time
    % pdfs

    Qmat.Q=Q;
    Qmat.Q_AA=QAA;
    Qmat.Q_FF=QFF;
    Qmat.Q_AF=QAF;
    Qmat.Q_FA=QFA;
    Qmat.kA=kA;
    Qmat.kE=kF;
    Qmat.k=kA+kF;

    [AZ00,AZ10,AZ11,~] = lik.calc_Z_constants(Qmat,expG_FF,kA+kF,kA,kF,1,0);

    %gamma constants

    uA = ones(kF, 1);
    AG00 = reshape(phiA'*reshape(permute(AZ00,[2 1 3]),3,4*7),7,4)*uA;
    AG10 = reshape(phiA'*reshape(permute(AZ10,[2 1 3]),3,4*7),7,4)*uA;
    AG11 = reshape(phiA'*reshape(permute(AZ11,[2 1 3]),3,4*7),7,4)*uA;

    %need asyptotic info for the asymptotic pdf. asymptotic roots requires
    %the structure form 
    
    Qmat.Q=Q;
    Qmat.Q_AA=QAA;
    Qmat.Q_FF=QFF;
    Qmat.Q_AF=QAF;
    Qmat.Q_FA=QFA;
    Qmat.kA=kA;
    Qmat.kE=kF;
    Qmat.k=kA+kF;

    % we need to find the asymptotic roots for the given Q matrix
    [open_roots,~]=asymptotic_roots(tres,Qmat.Q_AA,Qmat.Q_FF,Qmat.Q_AF,Qmat.Q_FA,kA,kF,0); 

    % we need the AR survivor matrices
    ARa=AR(open_roots,tres,Qmat.Q_AA,Qmat.Q_FF,Qmat.Q_AF,Qmat.Q_FA,Qmat.kA,Qmat.kE);      
    uF = ones(kF,1);

    %we have what we need for the areas
    open_areas = zeros(kA,1);
    for i=1:kA
        open_areas(i) = (-1 / open_roots(i)) * (phiA' * (reshape(ARa(:,:,i),kA,kA) * QAF * expG_FF) * uF);
    end

    f=zeros(length(t),1);
    for i=1:length(t)
        u = t(i)-tres;
        v = t(i)-(2*tres);
        if t(i) < tres
            f(i) = 0;
        elseif t(i) >= tres && t(i) <= 2*tres
            f(i) = sum(AG00.*exp(-eigsQ*(u)));
        elseif t(i) >= 2*tres && t(i) <= 3*tres
            f(i) = sum(AG00.*exp(-eigsQ*(t(i)-tres)) - (AG10+AG11*v).*exp(-eigsQ*(v)));
        else
            %asymptotic solution
            for j=1:length(open_roots)
                f(i) =  f(i)+(open_areas(j) / (-1/open_roots(j))) * exp(-(u) / (-1/open_roots(j)));
            end
        end 
    end
    p = t.*f;
end

