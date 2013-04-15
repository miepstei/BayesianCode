#include "mex.h"
#include "math.h"
#include "functions_lib.h"
#define sign(x) (( x > 0 ) - ( x < 0 ))


double bisect(const int MAX_TRIES,int tries,const double tol,double min,double max,double tres,double *Qxx_m,double *Qyy_m,double *Qxy_m,double *Qyx_m, int kx, int ky) {
    
    
    if (tries <= MAX_TRIES){
        double f_min = calc_detWs(min,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
        double f_max = calc_detWs(max,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
        
        if ((f_min > 0 && f_max <= 0) || (f_min < 0 && f_max >= 0)){
            double diff=fabs(max-min);
            if (diff > tol){
                double mid = (min+max)/2;
                double f_mid=calc_detWs(mid,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
                if (sign(f_mid) != sign(f_min)){
                	return bisect(MAX_TRIES,++tries,tol,min,mid,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);  
                } else if(sign(f_mid) != sign(f_max)){
                    return bisect(MAX_TRIES,++tries,tol,mid,max,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
                } else {
                    mexPrintf("Illegitimate root interval - no change in sign...");
                    return (min+max)/2;
                }
                
            } else {
                //within tolerance so accept midpoint of min and max
                return (min+max)/2;                  
            }         
        }
        
        
    } else{
        mexPrintf("MAX_TRIES Exceeded\n");
        return (min+max)/2;
    }     
}

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    /* inputs */
    
    
    const int max_tries = (int)mxGetScalar(prhs[0]);
    const double tol = mxGetScalar(prhs[1]);
    
    /* min,max,tries,tres,Qxx,Qyy,Qxy,Qyx,kx,ky */
    double min = mxGetScalar(prhs[2]);
    double max = mxGetScalar(prhs[3]);
    double tres = mxGetScalar(prhs[4]);
    
    double *Qxx_m = mxGetPr(prhs[5]);
    double *Qyy_m = mxGetPr(prhs[6]);
    double *Qxy_m = mxGetPr(prhs[7]);
    double *Qyx_m = mxGetPr(prhs[8]);
    
    int kx = (int)mxGetScalar(prhs[9]);
    int ky = (int)mxGetScalar(prhs[10]);  
    
    
    plhs[0] = mxCreateDoubleScalar(bisect(max_tries,1,tol,min,max,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky));
    
    
    
}

