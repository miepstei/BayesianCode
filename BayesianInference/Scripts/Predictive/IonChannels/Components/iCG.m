function icg = iCG(u,lambda,r)
    %Evaluates the integral \int^u_0 v^rexp(-lambda*v) dv
    if lambda < 1e-16
        icg = u^(r+1)/(r+1);
    else
        summate = 0;
        for j=0:r
            summate = summate + exp(-lambda*u) * ((lambda*u)^j)/factorial(j);
        end
        summate = 1 - summate;
        icg = summate * (factorial(r)/lambda^(r+1));
    end
end