function [asypdf ,open_areas ,open_roots, closed_asypdf , closed_areas, closed_roots] =  asymptotic_pdf(Q,kA,kF,t,tres)

    QAA = Q(1:kA,1:kA);
    QAF = Q(1:kA,kA+1:end);
    QFA = Q(kA+1:end,1:kA);
    QFF = Q(kA+1:end,kA+1:end);

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
    phiA=sum(inv(S*S'),2)';

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

    % we need to find the asymptotic roots for the given Q matrix
    [open_roots,~]=asymptotic_roots(tres,Qmat.Q_AA,Qmat.Q_FF,Qmat.Q_AF,Qmat.Q_FA,kA,kF,0); 

    % we need the AR survivor matrices
    ARa=AR(open_roots,tres,Qmat.Q_AA,Qmat.Q_FF,Qmat.Q_AF,Qmat.Q_FA,Qmat.kA,Qmat.kE);      

    uF = ones(kF,1);

    %we have what we need for the areas
    open_areas = zeros(kA,1);
    for i=1:kA
        open_areas(i) = (-1 / open_roots(i)) * (phiA * (reshape(ARa(:,:,i),kA,kA) * QAF * expG_FF) * uF);
    end

    f=zeros(length(t),1);
    for i=1:length(open_roots)
        f =  f+(open_areas(i) / (-1/open_roots(i))) * exp(-(t-tres) / (-1/open_roots(i)));
    end
    
    %set all times less than the resolution time to 0
    f(t<tres) = 0;

    asypdf = t.*f;
    
    %now the close time distrubutions
    %inital HJC vector for openings - solve phi*(I-eGAF*eGFA)=0
    I_phiF = eye(kF,kF) - (eG_FA*eG_AF);

    %plus one trick to solve for occupancy
    S=I_phiF;
    S(:,length(S)+1)=1;
    phiF=sum(inv(S*S'),2)';
    
     % we need to find the asymptotic roots for the given Q matrix
    [closed_roots,~]=asymptotic_roots(tres,Qmat.Q_FF,Qmat.Q_AA,Qmat.Q_FA,Qmat.Q_AF,kF,kA,0);    
    ARc=AR(closed_roots,tres,Qmat.Q_FF,Qmat.Q_AA,Qmat.Q_FA,Qmat.Q_AF,Qmat.kE,Qmat.kA);  
    uA = ones(kA,1);
    
    closed_areas = zeros(kF,1);
    
    for i=1:kF
        closed_areas(i) = (-1 / closed_roots(i)) * (phiF * (reshape(ARc(:,:,i),kF,kF) * QFA * expG_AA) * uA);
    end    
    
    f_c = zeros(length(t),1);
    
    for i=1:length(closed_roots)
        f_c =  f_c+(closed_areas(i) / (-1/closed_roots(i))) * exp(-(t-tres) / (-1/closed_roots(i)));
    end
    
    %set all times less than the resolution time to 0
    f_c(t<=tres) = 0;

    closed_asypdf = t.*f_c;    
    
end