function [t, open_pdf, open_areas ,open_roots] =  open_asymptotic_pdf(Q,kA,kF,tres,reduced,varargin)

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

    % we need to find the asymptotic roots for the given Q matrix
    [open_roots,~]=asymptotic_roots(tres,QAA,QFF,QAF,QFA,kA,kF,0); 
    
    % we need the AR survivor matrices
    ARa=AR(open_roots,tres,QAA,QFF,QAF,QFA,kA,kF);      

    uF = ones(kF,1);

    %we have what we need for the areas
    open_areas = zeros(kA,1);
    for i=1:kA
        open_areas(i) = (-1 / open_roots(i)) * (phiA * (reshape(ARa(:,:,i),kA,kA) * QAF * expG_FF) * uF);
    end
    
    if numel(varargin) > 0
        t=varargin{1};
    else
        t = logspace(log10(0.00001),log10(max(-1./open_roots)*20),512)';    
    end 
    
    f=zeros(length(t),1);
    for i=1:length(open_roots)
        f =  f+(open_areas(i) / (-1/open_roots(i))) * exp(-(t-tres) / (-1/open_roots(i)));
    end
    
    %set all times less than the resolution time to 0
    f(t<tres) = 0;

    open_pdf = t.*f;
        
end