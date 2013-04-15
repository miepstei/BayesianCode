#include "mex.h"
#include "matrix.h"
#include "math.h"
#include <limits>

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    
    //mexPrintf("%1.32f",std::numeric_limits<double>::epsilon());
    //Spectral dimensions are L by L by L where L-number of eigenvalues
    
    double *mx_spectral = mxGetPr(prhs[0]);
    double *eigens = mxGetPr(prhs[1]);
    double time = mxGetScalar(prhs[2]);
       
    const int *dim_spec = mxGetDimensions(prhs[0]);
    const int *dim_eigs = mxGetDimensions(prhs[1]);
    
    int num_dim = mxGetNumberOfDimensions(prhs[0]);
    
    for (int i = 0; i< num_dim;i++){
        //mexPrintf("The size of dimension %i is %i\n",i,dim_spec[i]);   
    }
    
            
    plhs[0]=mxCreateDoubleMatrix(dim_spec[0], dim_spec[1], mxREAL);
    double *result = mxGetPr(plhs[0]);
               
    
    //we have a 3-D matrix, a collection of eigenvectors and a time component
    //we want to output a 2-D exponentiation matrix
    
    int obs=dim_spec[0]*dim_spec[1]*dim_spec[2];
    int layer = dim_spec[0]*dim_spec[1];
    
    for (int j = 0; j < layer; j++){
        result[j]=0;
    }

    if (num_dim >2){
        //dealing with a 3_D matrix
        for (int i = 0; i < dim_spec[2];i++){        
            double exponent = exp(eigens[i]*time);
            //mexPrintf("depth dimension %i, exponent %f eigs %f, time %f\n",i,exponent,eigens[i],time);
            for (int j = 0; j < layer; j++){
                result[j]=result[j]+(mx_spectral[(i*layer+j)]*exponent);
                //mexPrintf("elem %i val %f result %f \n",i,mx_spectral[(i*layer+j)],result[j]); 
            }
        }
    }
    else{
        //dealing with a scalar
        double t = eigens[0]*time;
        //mexPrintf("spectral %1.20f,exp %1.20f, eigs %1.20f, time %1.20f\n",mx_spectral[0],exp(t),eigens[0],time);
        result[0] = mx_spectral[0]*exp(t);
    }
    
    
}

