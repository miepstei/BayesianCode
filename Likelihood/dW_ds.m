function dW = dW_ds( s,tres,Qxy,Qyy,Qyx,kx,ky )
%dW_ds Derivative of the W(s) function wrt. s of the subgroup 'x' of states
%(typically the open states A or the closed states F)
% typically employed where the value of s is a root of W(s)

%   ARGUMENTS:
%   s: typically a root os W(s)
%   tres: time resolution of the experiment
%   Qxy: submatrix of the Q-matrix either A by F or F by A
%   Qyy: submatrix of the Q-matrix either F by F or A by A
%   Qyx: submatrix of the Q-matrix either F by A or A by F
%   kx: number of states in subgrp x
%   ky: number of states in subgroup y

%   OUTPUTS:
%   dW: kx by kx derivative submatrix

%   MATHS
%   W'(s) is defined in Colqhoun and Hawkes 1992 equation 56:
%   I+[Qxy*[S^*_yy(s)(sI-Qyy)^-1 - tres(I-S*_yy(s))]G*_yx(s)]

%   where \int^{tres}_0 e^{-st}exp^{Q_{yy}t} dt 
%    = [I-e^{s(sI-Qyy)*tres}](sI-Qyy)^-1
%    = S^*_yy(s)*(sI-Qyy)^-1
%   
%   and eGyx = (sI-Qyy)^{-1} * Qyx

Iy=eye(ky);
Ix=eye(kx);
sI_Qyy=s*Iy-Qyy;

lik=Likelihood();
[spec,eig_vals]=lik.spectral_expansion((sI_Qyy));

exp_sI_Qyy=lik.mat_exponentiation(-eig_vals,spec,tres);
S_yy=Iy-exp_sI_Qyy;
eGyx=(sI_Qyy)^-1*Qyx;

dW=Ix + Qxy*(S_yy*(sI_Qyy^-1)-tres*(Iy-S_yy))*eGyx;


end

