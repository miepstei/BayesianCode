function [t, close_pdf , closed_areas, closed_roots] =  close_asymptotic_pdf(Q,kA,kF,tres,reduced,varargin)

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
    I_phiF = eye(kF,kF) - (eG_FA*eG_AF);

    %plus one trick to solve for occupancy
    S=I_phiF;
    S(:,length(S)+1)=1;
    phiF=sum(inv(S*S'),2)';
    
    % we need to find the asymptotic roots for the given Q matrix
    [closed_roots,~]=asymptotic_roots(tres,QFF,QAA,QFA,QAF,kF,kA,0);
    
    % we need the AR survivor matrices
    ARc=AR(closed_roots,tres,QFF,QAA,QFA,QAF,kF,kA);  
    
    uA = ones(kA,1);
    
    closed_areas = zeros(kF,1);
    
    for i=1:kF
        closed_areas(i) = (-1 / closed_roots(i)) * (phiF * (reshape(ARc(:,:,i),kF,kF) * QFA * expG_AA) * uA);
    end    
    
    if numel(varargin) > 0
        t=varargin{1};
    else
        t = logspace(log10(0.00001),log10(max(-1./closed_roots)*20),512)';    
    end     
    
    f_c = zeros(length(t),1);
    for i=1:length(closed_roots)
        f_c =  f_c+(closed_areas(i) / (-1/closed_roots(i))) * exp(-(t-tres) / (-1/closed_roots(i)));
    end
    
    %set all times less than the resolution time to 0
    f_c(t<=tres) = 0;

    close_pdf = t.*f_c;    
    
end