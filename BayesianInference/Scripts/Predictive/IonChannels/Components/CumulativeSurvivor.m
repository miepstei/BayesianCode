function Ku = CumulativeSurvivor(u,tres,qm,kA,isopen,dcpoptions)
    %Calculates the cumulative survivor function K(u) (as opposed to the pdf)
    %inputs u - duration (t-tres)
    %tres - solution time
    %qm - qmatrix
    %kA - number of open states
    %is open - calculate for A states, else F states


Ku=0;
lambdas = eig(-qm,'nobalance');
kF=length(lambdas)-kA;
if u >=0
    if u <= 2* tres
        for i=0:length(lambdas)-1
            for m = 0:fix(u/tres)
                for r = 0:m
                    Ku=Ku+((-1)^m) * dcpExactSurvivorRecursion(qm,kA,tres,isopen,i,m,r) * iCG(u-(m*tres),lambdas(i+1),r);
                end
            end
        end
    else
       %asymptotic solution
       %exact cumulation to 2* tres
       v=2*tres;
       for i=0:length(lambdas)-1
            for m = 0:1
                for r = 0:m
                    Ku=Ku+((-1)^m) * dcpExactSurvivorRecursion(qm,kA,tres,isopen,i,m,r) * iCG(v-(m*tres),lambdas(i+1),r);
                end
            end
       end
       if isopen
           for i = 1:kA
               [AR_i,tau] = dcpAsymptoticSurvivorExponentXt(qm,kA,tres,i-1,isopen,dcpoptions);
               timeConstant = -1/tau;
               Ku=Ku+(AR_i*timeConstant*(exp((-2*tres)/timeConstant) - exp(-u/timeConstant)));  
           end
       else
           for i = 1:kF
               [AR_i,tau] = dcpAsymptoticSurvivorExponentXt(qm,kA,tres,i-1,isopen,dcpoptions);
               timeConstant = -1/tau;
               Ku=Ku+(AR_i*timeConstant*(exp((-2*tres)/timeConstant) - exp(-u/timeConstant)));  
           end
       end
    end
end