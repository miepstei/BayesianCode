function [open_t, open_p, open_areas, open_taus] = open_ideal_pdf(Q,kA,kF,tres,reduced,varargin)
   
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

    open_equil_states = equil_states(kF:end);
    nom = open_equil_states*QFA;
    denom = sum(nom);
    open_equil_states = nom/denom;
    
    w=zeros(kA,1);
    [spect, eigs, ~] = lik.spectral_expansion(-QAA);

    for i=1:kA
        w(i) = (open_equil_states * squeeze(spect(i,:,:))) * -QAA * ones(kA,1);
    end

    fac = 1/sum((w./diag(eigs))' * exp(-tres * diag(eigs)));

    open_areas = w ./ diag(eigs);
    open_taus = 1./diag(eigs);
    
    %work out the logspacing if not provided

    if numel(varargin) > 0
        open_t=varargin{1};
    else
        [open_roots,~]=asymptotic_roots(tres,QAA,QFF,QAF,QFA,kA,kF,0);
        open_t = logspace(log10(0.00001),log10(max(-1./open_roots)*20),512)';    
    end 
    
    f=zeros(length(open_t),1);
    
    for i=1:length(open_taus)
        f =  f+(open_areas(i) / open_taus(i)) * exp(-open_t / open_taus(i));
    end

    open_p = open_t.*f*fac;    
end