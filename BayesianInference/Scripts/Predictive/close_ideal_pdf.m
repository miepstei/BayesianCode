function [close_t,close_p,close_areas,close_taus] = close_ideal_pdf(Q,kA,kF,tres,reduced,varargin)

    %load('Data/AchRealData.mat')
    %model = SevenState_10Param_QET();
    %startParams=[  2.12694727e+03   5.22450234e+04   5.95298145e+03   5.67086411e+01 5.61611836e+04   8.89628830e+01   1.00000000e+08   1.52130078e+03 9.46586621e+03   4.14601856e+08]';

    %Q=model.generateQ(startParams,1);
    %load('/Volumes/Users/Dropbox/Academic/PhD/Code/dc-pyps-new/pdftest.mat')
    
    QAA = Q(1:kA,1:kA);
    QAF = Q(1:kA,kF:end);
    QFA = Q(kF:end,1:kA);
    QFF = Q(kF:end,kF:end);

    %lik
    lik=Likelihood();

    if reduced
        %solve equilibrium occupancies by reduced Q method
        Qr = bsxfun(@minus,Q,Q(end,:));
        r = Q(end,1:end-1);
        Qr = Qr(1:end-1,1:end-1); 
        equil_states = -r*Qr^-1;
        equil_states(end+1) = 1-sum (equil_states);

    else
        %open equilibrium occupanies by row addition
        S=Q;
        S(:,length(S)+1)=1;
        equil_states=sum(inv(S*S'),2)';        
    end
       
    closed_equil_states = equil_states(1:kA);
    nom = closed_equil_states*QAF;
    denom = sum(nom);
    closed_equil_states = nom/denom;
    
    w=zeros(kF,1);
    [spect, eigs, ~] = lik.spectral_expansion(-QFF);
    
    for i=1:kF
        w(i) = (closed_equil_states * squeeze(spect(i,:,:))) * -QFF * ones(kF,1);
    end    
    
    fac = 1/sum((w./diag(eigs))' * exp(-tres * diag(eigs)));
    
    close_areas = w ./ diag(eigs);
    close_taus = 1./diag(eigs);
    
    %work out the logspacing if not provided

    if numel(varargin) > 0
        close_t=varargin{1};
    else
        [close_roots,~]=asymptotic_roots(tres,QFF,QAA,QFA,QAF,kF,kA,0);
        close_t = logspace(log10(0.00001),log10(max(-1./close_roots)*20),512)';    
    end 
    
    fc=zeros(length(close_t),1);

    for i=1:length(close_taus)
        fc =  fc+(close_areas(i) / close_taus(i)) * exp(-close_t / close_taus(i));
    end
    
    close_p = close_t.*fc*fac;
end