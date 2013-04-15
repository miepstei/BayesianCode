function  [roots,debug]  = asymptotic_roots( tres, Qxx, Qyy, Qxy, Qyx, kx, ky,debugOn )
%This is a function to find the real roots of the asymptotic function which
%corrects for missed events
%The asymptotic behaviour of the suvivor function A^R(t) and therefore of
%the pdf F_T(t) is governed by the solutions (or roots) of the equation
%det(W(s))=0. where
%W(s)-sI-H(s) (Col & Hawkes 1992 eq 52)
%
%some more notes for guidance:
%
%If H(s) is irreducible (all states intercommunicate) det(W(s)) always has
%one real root s1<0 which is greater than the real part of any other
%complex root and asypototically A^R(t) ~ e^{s1t}frac{c1r1}{r1}dW(s1)c1
%where c1 and r1 are column and row eigenvectors and dW(s) is the matrix
%derivative of W(s) evaluated at W(s)

%If H(s) is also reversible (assumed in the ion-channel literature) then
%det(W(s)) has exactly k_A real roots, which, if they are dinstinct, then 
%A^R(t) ~ \sum^{K_A}_{i=1}e^{s1t}frac{ciri}{ri}dW(si)ci
%The derivative of W(s) is given by
%I+Q_AF[S*_FF(s)(sI-Q_FF)^-1-\tau(I-S*_FF(s)]])G*_FA(s)
% to calculate the pdf we need to calculate the areas of each component corresponding to each root. 

%max and min range to search for roots.
min=-1000000;
max=-0.0000001;

debug=struct('');

% we need an array of kA start and end points between which a single root
% can be found

lmin=count_eigs(min,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
lmax=count_eigs(max,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);

if lmin > 0
    %need to increase the search space by increasing the negative size of
    %lmin
    min=min*4;
end

if lmax < kx % [QUERY]-I think this should be kx as we want to find all the kx roots...
    %all the roots are not captured at the max bound so reduce it further
    max=max/4;
end

%now we want to find roughly suitable intervals between which we can be sure only a
%single root exists for the extended search process
        
%keep root seaching the same as in scipy.optimize
MAX_SEARCH=100;
iter=0;

root_intervals=intervals(); %handle object, pass by ref, collects root intervals in recursion
bisect_intervals(min,max,tres,Qxx,Qyy,Qxy,Qyx,kx,ky,0,MAX_SEARCH,iter,root_intervals);

if debugOn==1
    debug=struct('intervals',root_intervals);
end

%lets do it
rtol=4.4408920985006262e-16; %tolerance to match scipy.optimize.bisect
ftol=1e-12;
MAX_TRIES=100;
%detWs = @(s,varargin) det(Ws_mex(s,varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7}/Ws);
roots=zeros(kx,1);
for i=1:kx
    tol=ftol+(rtol*(abs(root_intervals.t(i).min)+abs(root_intervals.t(i).max)));
    roots(i)=bisect(MAX_TRIES,tol,root_intervals.t(i).min,root_intervals.t(i).max,tres,Qxx, Qyy, Qxy, Qyx, kx, ky);
end

roots=sort(roots);

end

function no = count_eigs(s,tres,Qxx,Qyy,Qxy,Qyx,kx,ky)
    %Find number of eigenvalues of H(s) that are equal to or less than s.
    Hxx = Hs_mex(s,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
    eVals=eig(Hxx);
    no=sum(eVals<=s);
end

function bisect_intervals(low,high,tres,Qxx,Qyy,Qxy,Qyx,kx,ky,found,max_search,searches,root_intervals)
    %recursive function to determine decent starting locations for the main
    %root finding algorithm
    %fprintf('searches %i\n',searches);
    if searches >= max_search
        root_intervals.add(low,high);
        return
    end

    if found~=kx 
       eigs_low=count_eigs(low,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
       eigs_high=count_eigs(high,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
       if eigs_high-eigs_low == 1
           %we have a single root in the interval low -> high so save in data
           %structure
           found=found+1;
           root_intervals.add(low,high);

       elseif (eigs_high-eigs_low) >1
           %we have more than one root in this interval, we need to split again
           mid=(low+high)/2.0;
           searches=searches+1;
           bisect_intervals(mid,high,tres,Qxx,Qyy,Qxy,Qyx,kx,ky,found,max_search,searches,root_intervals);
           searches=searches+1;
           bisect_intervals(low,mid,tres,Qxx,Qyy,Qxy,Qyx,kx,ky,found,max_search,searches,root_intervals);

       end

    end


end
