function R=AR(roots,tres,Qxx,Qyy,Qxy,Qyx,kx,ky)
% To evaluate the 'survivor function' A^R(t) which is the pdf which
% represents the probability of an open period of length t with zero, one or more
% short intervals less than tres. It's the key to evaulating the overall
% pdf f(t)=\phi_{A}eG_{AF}(t+tres)u_F
%         =\phi_{A}A^{R(t)}Q_{AF}e^{Q_{FF}tres}u_{F}
%
% ARGUMENTS
%     roots:the roots of the substate x from the function H(s) where
%     det[H(s)]=0
%     tres: time resolution
%     Qxx: subpartition of matrix Q with substates x
%     Qyy: subpartition of matrix Q with substates y
%     Qxy: subpartition of matrix Q with substates x by y
%     Qyx: subpartition of matrix Q with substates y by x
%     kx: number of states in subparition x
%     ky: number of states in subparition y

%     OUTPUT
%     AR: a kx by kx by kx matrix

%     MATHS: as t -> \infty and det(w(s))=0 has kx distinct roots 
%     AR ~ \sum^{x}_{i=1} \frac{w^{s_{i}t}c_{i} r_{i}}{c_{i}W'(s_{i})c_{i}}
%     where c_i and r_i are the left and right eigenvectors of H(s_i) where
%     s_i is the ith root of det(w(s))=0.


R=zeros(kx,kx,kx);

left=zeros(kx,kx);
right=zeros(kx,kx);
u=ones(kx,1);

for i=1:kx
   W=Ws_mex(roots(i),tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
   
   %left eigenvectors given as a solution to the equations
   %pW=0, pu=1, like the solution of equilibrium distribution (1992)
   % not sure why we can't use the eigenvectors of say eigs(Ws) here
   u=ones(length(W),1);
   S=[W u];
   
   if rcond(S*S')< 1e-16
       err = MException('AR:SingularMatrix', ...
           'LEFT eigenvectors - x matrix from reduced Q-method is singular %f',rcond(x));
       throw(err)
   end

   left(i,:) = u'*(S*S')^-1;
   
   %solving using the reduced Q-method to prevent ill-conditioned arrors
   %when (S*S') is singular
   %x=bsxfun(@minus,W(1:end-1,:),W(end,:));
   %x=x(:,1:end-1);
   %r=W(end,1:end-1);
   %if rcond(x)< 1e-16
   %    err = MException('AR:SingularMatrix', ...
   %     'LEFT eigenvectors - x matrix from reduced Q-method is singular %f',rcond(x));
       %throw(err);
   %end
   %solution = -r*x^-1;
   %solution(length(solution)+1) = 1-sum(solution);
   %left(i,:) = solution;
   
   %right eigenvectors
   S=[W' u]; 
   if rcond(S*S')< 1e-16
       err = MException('AR:SingularMatrix', ...
       'RIGHT eigenvectors - x matrix from reduced Q-method is singular %f',rcond(x));
       %throw(err);
   end      
   
   right(i,:)=u'*(S*S')^-1;
   
   %W=W';
   %x=bsxfun(@minus,W(1:end-1,:),W(end,:));
   %x=x(:,1:end-1);
   %r=W(end,1:end-1);
   %if rcond(x)< 1e-16
   %    err = MException('AR:SingularMatrix', ...
   %    'RIGHT eigenvectors - x matrix from reduced Q-method is singular %f',rcond(x));
       %throw(err);
   %end   

   %solution = -r*x^-1;
   %solution(length(solution)+1) = 1-sum(solution);
   %right(i,:)=solution;
   
end
right=right';

for i=1:kx
   %want a kx by kx matrix constituting the left and right eigenvectors 
   nom=right(:,i)*left(i,:);
   dW=dW_ds(roots(i),tres,Qxy,Qyy,Qyx,kx,ky); 
   denom=right(:,i)'*dW*left(i,:)';
   R(:,:,i)=nom/denom;
end

end