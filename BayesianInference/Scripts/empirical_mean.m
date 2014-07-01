
mu=[0,0];
for t=1:adaption_samples.N
    mu=mu+((adaption_samples.params(t,:)-mu)/t);
end
summ=0;
for t=1:adaption_samples.N
    summ = summ+(adaption_samples.params(t,:)-mu)'* (adaption_samples.params(t,:)-mu);
end
covar = summ/(t-1);

covar = [0,0;0,0];
mu1=[0,0];
mu2=[0,0];
% for t=1:adaption_samples.N
%     mu1=mu1+((adaption_samples.params(t,:)-mu1)/t);
%     
%     %intermediate = (adaption_samples.params(i,:)-mu2)'*(adaption_samples.params(i,:)-mu1);
%     %covar = covar + (intermediate-covar)/i;
%     covar = (t-1/t)*covar;
%     intermediate = (t*(adaption_samples.params(t,:)-mu2)'*(adaption_samples.params(t,:)-mu2));
%     intermediate = intermediate - (t+1)*(adaption_samples.params(t,:)-mu1)'*(adaption_samples.params(t,:)-mu1);
%     intermediate = intermediate + adaption_samples.params(t,:)'*(adaption_samples.params(t,:));
%     intermediate = intermediate*(1/t);
%     covar = covar+intermediate;
%     mu2=mu2+((adaption_samples.params(t,:)-mu2)/t); 
%    % disp(covar_estimate-cov(adaption_samples.params(1:t,:)))
% end
summ=zeros(2,2);
mus=zeros(1,2);
for k=1:adaption_samples.N
    summ = summ + adaption_samples.params(k,:)'*(adaption_samples.params(k,:));
    mus= mus+adaption_samples.params(k,:);
end
mus=mus/(k+1);
abc = (1/k)*(summ-((k+1)*(mus'*mus)));

disp(cov(adaption_samples.params))
    