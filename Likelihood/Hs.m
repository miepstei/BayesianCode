function Hxx_s = Hs( s, tres, Qxx, Qyy, Qxy, Qyx, ky )
%ARGUMENTS:
%s-scalar input value in units of frequency,s into the function
%tres-scalar resolution time of the recording
%Qxx - matrix, square subpartition of Q matrix (i.e. AA or FF)
%Qyy - matrix, opposing square subpartition of Q matrix (i.e. FF or AA)
%Qxy - x by y matrix, subpartition of Q matrix (i.e. AF or FA)
%Qyx - y by x matrix, subpartition of Q matrix (i.e. FA or AF)
%ky - number of states in subgroup y (kF or kA)

%OUTPUTS
% Hxx(s) - a matrix of x by x with the function values

%MATHS
%H(s) function is RHS of AR function, 
%H(s)Q_AA+[QAF*\int^{tres}_{0}e^{-st}e^{Q_{FF}t}*Q_{FA}]
%or
%if s is not an eigenvalue of Q_{FF} so [sI-Q_{FF}]^{-1}
%exists,
%H(s) = Q_{AA}+Q_{AF}(sI-Q_{FF})^{-1}(I-e^{-(sI-Q_{FF}\tau)})Q_{FA}

I=eye(ky);

%this probably needs refactoring our of the Likelihood class
%lik=Likelihood();
%[spec,eig_vals]=lik.spectral_expansion((s*I-Qyy));
%expMat=lik.mat_exponentiation(-eig_vals,spec,tres);

%mex function for calculating the exponential of a matrix
expMat=expm(-(s*I-Qyy)*tres);
%[V,D] = eig(s*I-Qyy);
%expMat=(V*exp(tres*-D)*V^-1);
%expMat=expm(tres*(s*I-Qyy));
%disp(expMat-expMat2)

Hxx_s=Qxx+(Qxy*(s*I-Qyy)^-1)*(I-expMat)*Qyx;
%Hxx_s=Qxy*(s*I-Qyy)^-1;
%Hxx_s=Hxx_s*(I-expMat);
%Hxx_s=Hxx_s*Qyx;
%Hxx_s=Qxx+Hxx_s;

end

