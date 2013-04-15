function detWs = detWxx_s( s, tres, Qxx, Qyy, Qxy, Qyx, kx, ky )
    
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
    %det Wxx(s) - determinant of the matrix function Ws
    
    
    detWs=det(Ws(s, tres, Qxx, Qyy, Qxy, Qyx, kx, ky));

end
