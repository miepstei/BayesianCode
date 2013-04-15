log_matrix = zeros(size(A,1),size(B,2));
log_matrix2 = zeros(size(A,1),size(B,2));
%assume A and B are elementwise logs

for i=1:size(A,1)
    for j=1:size(B,2)
        a=A(i,:);
        b=B(:,j);
        product=zeros(size(a,2),1);
        for k=1:size(a,2)
            product(k)=a(k)*b(k);
        end
        product=sort(product,'descend');
        sum=0;
        for m=2:length(product)
            sum=sum+exp(log(product(m))-log(product(1)));
        end
        
        elem_log=log(product(1))+log(1+sum);
        log_matrix(i,j)=elem_log;
    end
end

%assume A and B are elementwise logs

log_A=log(A);
log_B=log(B);

for i=1:size(log_A,1)
    for j=1:size(log_B,2)
        a=log_A(i,:);
        b=log_B(:,j);
        product=zeros(size(a,2),1);
        for k=1:size(a,2)
            product(k)=a(k)+b(k);
        end
        product=sort(product,'descend');
        sum=0;
        for m=2:length(product)
            sum=sum+exp(product(m)-product(1));
        end
        elem_log=product(1)+log(1+sum);
        log_matrix2(i,j) = elem_log;
    end
end