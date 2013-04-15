#include "mex.h"
#include "matrix.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    double *mx_a = mxGetPr(prhs[0]);
    const int *dimensions = mxGetDimensions(prhs[0]);
    int num_dim = mxGetNumberOfDimensions(prhs[0]);
    
    for (int i = 0; i< num_dim;i++){
        mexPrintf("The dimension %i is %i",i,dimensions[i]);   
    }
    
}