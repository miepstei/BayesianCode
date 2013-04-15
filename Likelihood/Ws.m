function Wxx_s = Ws( s, tres, Qxx, Qyy, Qxy, Qyx, kx, ky )
    
    %ARGUMENTS
    %s-scalar input value in units of frequency,s into the function
    %tres-scalar resolution time of the recording
    %Qxx - matrix, square subpartition of Q matrix (i.e. AA or FF)
    %Qyy - matrix, opposing square subpartition of Q matrix (i.e. FF or AA)
    %Qxy - x by y matrix, subpartition of Q matrix (i.e. AF or FA)
    %Qyx - y by x matrix, subpartition of Q matrix (i.e. FA or AF)
    %kx - number of states in subgroup x (kA or kF)
    %ky - number of states in subgroup y (kF or kA)
    
    %OUTPUTS
    %Wxx(s) - a matrix of x by x with the function values
    
    %MATHS
    %Evaluate W(s) function .
    %WAA(s) = sI - HAA(s)
    %W(s) is the denominator of the suvivor function AR(s)
    % we are interested in finding the values of s which render this 
    %matrix singular, i.e det (W(s))=0
    
    sI=s*eye(kx);
    Wxx_s=sI-Hs(s, tres, Qxx, Qyy, Qxy, Qyx, ky);

end

