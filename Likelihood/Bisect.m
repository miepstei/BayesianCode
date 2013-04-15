function [fx,iter] = Bisect(tol,min,max,tries,tres,Qxx,Qyy,Qxy,Qyx,kx,ky)
%generic bisection routine
%we know that the function is bounded by min/max
%NOTE - Matlab has a recursion limit of 500 by default

%INPUTS - func: @function_handle to function call to be evaluated
%         tol: tolerance level for finding the root e.g 1^-05
%         min: lower interval where one root resides with certainty
%         max: highre interval where one root resides with certainty
%         tries: the number of attempts the recursive function is currently
%         on
%         varargin: variable number of arguments to evaluate func

MAX_TRIES=100;
%iter=tries;
%fprintf('tries %i \n',tries);
if tries <= MAX_TRIES

    f_min=detWs_mex(min,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
    f_max=detWs_mex(max,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);

    if (f_min > 0 && f_max <= 0) || (f_min < 0 && f_max >= 0)
        % we have a legitimate root interval
        diff=abs(max-min);
        

        if diff > tol
            %recurse
            mid=(min+max)/2;
            f_mid=detWs_mex(mid,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
            if sign(f_mid) ~= sign(f_min)
                %root lies between f_mid and f_min 
                tries=tries+1;
                %fprintf('interval %f to %f\n',min,mid);
                [fx,iter]=Bisect(tol,min,mid,tries,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
            elseif sign(f_mid) ~= sign(f_max)
                %root lies between f_mid and f_max
                tries=tries+1;
                %fprintf('interval %f to %f\n',mid,max);
                [fx,iter]=Bisect(tol,mid,max,tries,tres,Qxx,Qyy,Qxy,Qyx,kx,ky);
            else
                fprintf('Illegitimate root interval - no change in sign...')
            end
        else
            %within tolerance so accept midpoint of min and max
            fx=(min+max)/2;
            iter=tries;
        end

    else
       fprintf('Illegitimate root interval...')
    end
else
    %fprintf('MAX_TRIES exceeded...\n')
    fx=(min+max)/2;
    iter=tries;
    
end

end


