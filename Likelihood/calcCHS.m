function [ start, finish ] = calcCHS( Froots,tres,tcrit,Q_FA,kA,expQAA,phiF,f_AR )
%calcCHS calculating the start and end vectors based on knowledge that the
%tcrit must be longer than tres.
%   INPUTS

%   OUTPUTS


%   MATHS

coeff = -exp(Froots * (tcrit - tres)) ./ Froots;

%shiftdim operation is necessary as in python 2nd dimension = 3rd dimension
%in MATLAB
%temp = reshape(reshape(f_AR,size(f_AR,1)*size(f_AR,2),size(f_AR,3))*coeff,size(f_AR,1),size(f_AR,2)); 
temp = reshape(f_AR.mat*coeff,f_AR.size(1),f_AR.size(2));
%temp = sum(f_AR * coeff);
H = (temp*Q_FA)*expQAA;

u=ones(kA,1);
start=(phiF*H)/(phiF*H*u);
finish=H*u;


end

