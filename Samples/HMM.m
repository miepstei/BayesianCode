%%A test hmm, fwd/bwd agorithm implementation

%prior distibution of hidden states
P=[0.5 0.5];

%transition matix
T=[0.7 0.3; 0.3 0.7];

%Observation probabilities
B=[0.9 0.1; 0.2 0.8];

%observation sequences
%1 - Rain
%2 - no rain
O=[1 1 2 1 1];


%forward probabilities
%the probability of ending up in any particular state given the first observations in the sequence, i.e. 
%P(X_k|O(1:k))

for i=1:length(P)
   f(1,i)=P(i)*B(i,O(i));
end
f(1,:)=f(1,:)/sum(f(1,:));

%f(1)=T*P';

for j=2:length(O)
    for i=1:length(P)
        f(j,i)=0;
        for k=1:length(P)
            f(j,i)=f(j,i)+f(j-1,k)*T(i,k)*B(i,O(j));
        end
        
    end
    f(j,:)=f(j,:)/sum(f(j,:));
end


%backward probabilities
%the probability of ending up in any particular state given the first observations in the sequence, i.e. 
%P(X_k|O(k+1:T))

for i=1:length(P)
   b(length(O),i)=1; 
end

for j=length(O)-1:-1:1
    for i=1:length(P)
        b(j,i)=0;
        for k=1:length(P)
           b(j,i)=b(j,i)+b(j+1,k)*T(i,k)*B(k,O(j+1));
        end
    end
    b(j,:)=b(j,:)/sum(b(j,:));
end

%These two sets of probability distributions can then be combined to obtain
%the distribution over states at any specific point in time given the 
%entire observation sequence:
%P(X_k | O(1:T) = P(X_k \mid O_{1:k},O_{k+1:T)
%P(X_k | O(1:T) \propto  P(X_k|O(k+1:T) * P(X_k|O(1:k))


