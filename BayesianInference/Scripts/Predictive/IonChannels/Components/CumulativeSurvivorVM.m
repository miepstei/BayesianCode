function Mu = CumulativeSurvivorVM(u,tres,qm,kA,isopen,dcpoptions)
    %Calculates the cumulative survivor function M(u) (as opposed to the pdf)
    %inputs u - duration (t-tres)
    %tres - solution time
    %qm - qmatrix
    %kA - number of open states
    %is open - calculate for A states, else F states

kF = size(qm,1)-kA;

if isopen
    Mu=zeros(kA,kA);
else
    Mu=zeros(kF,kF);
end


lambdas = eig(-qm,'nobalance');
if u >=0
    if u <= 2* tres
        for i=0:length(lambdas)-1
            for m = 0:fix(u/tres)
                for r = 0:m
                    Mu=Mu+((-1)^m) * dcpExactSurvivorRecursion(qm,kA,tres,isopen,i,m,r) * ((tres* m * iCG(u-(m*tres),lambdas(i+1),r)) + iCG(u-(m*tres),lambdas(i+1),r+1));
                end
            end
        end
    else
       %asymptotic solution
       %exact cumulation to 2* tres
       v=2*tres;
       for i=0:length(lambdas)-1
            for m = 0:fix(v/tres)
                for r = 0:m
                    Mu=Mu+((-1)^m) * dcpExactSurvivorRecursion(qm,kA,tres,isopen,i,m,r) * ((tres* m * iCG(v-(m*tres),lambdas(i+1),r)) + iCG(v-(m*tres),lambdas(i+1),r+1));
                end
            end
       end
       
       %cumulate the asymptotic component
       if isopen
           for i = 1:kA
             [AR_i,tau] = dcpAsymptoticSurvivorExponentXt(qm,kA,tres,i-1,isopen,dcpoptions);
              timeConstant = -1/tau;
              Mu=Mu+(AR_i * timeConstant * (((timeConstant + (2*tres)) * (exp((-2*tres)/timeConstant))) - ((timeConstant+u) * exp(-u/timeConstant))));  
           end
       else
           for i = 1:kF
              [AR_i,tau] = dcpAsymptoticSurvivorExponentXt(qm,kA,tres,i-1,isopen,dcpoptions);
              timeConstant = -1/tau;
              Mu=Mu+(AR_i * timeConstant * (((timeConstant+ (2*tres)) * (exp((-2*tres)/timeConstant))) - ((timeConstant+u) * exp(-u/timeConstant))));  
           end
       end
       
    end
end