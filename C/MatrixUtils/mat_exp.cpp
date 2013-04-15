#include "mex.h"
#include "matrix.h"
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include <stdio.h>

using namespace std;

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    /* params */
   //double a[9] = {1,2,3,4,5,6,7,8,9};
   //double b[9] = {0};
   
   double *A = mxGetPr(prhs[0]);   
   int rows = mxGetM(prhs[0]);
   int cols = mxGetN(prhs[0]);
   
   //pointers to gsl_matrices 
   gsl_matrix *m; 
   gsl_matrix *em;
   
   if(rows != cols){
       mexErrMsgTxt("Inner dimensions are not equal");
       return;
   }
     
   /* allocate memory for a matrix */
   m = gsl_matrix_alloc(rows,cols); 
   em = gsl_matrix_alloc(rows,cols);
   
   /* initialise the matrices with data */
   for (int i=0;i<rows;i++){
        for (int j=0;j<cols;j++){
	        gsl_matrix_set(m,i,j,A[(j*rows)+i]);
            gsl_matrix_set(em,i,j,0);
	    }
    }
   
   /* call the matrix exponential function */
   gsl_linalg_exponential_ss(m, em, .01);
   
   //get a Pointer to the mxrray and fill it
   plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);    
   double *out = mxGetPr(plhs[0]);
   

   for (int i=0;i<rows;i++){
      for (int j=0;j<cols;j++){
          out[(j*rows)+i] = gsl_matrix_get(em,i,j);
	  }
   }
   
   //free memory for gsl data structures
   gsl_matrix_free(m);
   gsl_matrix_free(em);
    
}
