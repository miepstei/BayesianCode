#include "mex.h"
#include "matrix.h"
#include "functions_lib.h"
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include <stdio.h>

using namespace std;

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    /* params */

   double s = mxGetScalar(prhs[0]);
   
   double tres = mxGetScalar(prhs[1]);
   
   double *Qxx_m = mxGetPr(prhs[2]);
   double *Qyy_m = mxGetPr(prhs[3]);
   
   double *Qxy_m = mxGetPr(prhs[4]);
   double *Qyx_m = mxGetPr(prhs[5]);
   int kx = (int)mxGetScalar(prhs[6]);
   int ky = (int)mxGetScalar(prhs[7]);
   
   gsl_matrix *ws = calc_Ws(s,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
   //need to return the results in a way MATLAB understands
   
   plhs[0] = mxCreateDoubleMatrix(kx, kx, mxREAL);
   double *out = mxGetPr(plhs[0]);

   
   for (int i=0;i<kx;i++){
      for (int j=0;j<kx;j++){
          out[(j*kx)+i] = gsl_matrix_get(ws,i,j);
	  }
   }   
   
   //cleanup
   gsl_matrix_free(ws);
}