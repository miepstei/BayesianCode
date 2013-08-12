#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include <iostream>


using namespace std;
void mex_test();

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    /* params */
    
    /* first is the array of burst intervals
     needs to be parsed into a vector of vectors*/
    
    if (nrhs != 5)
        mexErrMsgTxt ("Five arguments expected - bursts,Q-matrix,tau,tcrit,open_states");
    
    if (! mxIsCell (prhs[0]))
        mexErrMsgTxt ("expects cell array of burst intervals");
    
    DCProgs::t_Bursts dbursts;
    
    int n = mxGetNumberOfElements (prhs[0]);

    for (int i = 0; i < n; i++) {
        mxArray* mburst = mxGetCell (prhs[0], i);
        
        int ncols = mxGetN(mburst);
        int nrows = mxGetM(mburst);
        
        //mexPrintf("rows, cols %i,%i\n",ncols,nrows);
        
        if (ncols < nrows || nrows != 1){
            mxFree(mburst);
            mexErrMsgTxt ("burst array should be 1*n");   
        } 
        
        double *elements = mxGetPr(mburst);
        DCProgs::t_Burst dburst;       
        for (int j=0; j < ncols; j++){
            dburst.push_back(elements[j]);
        }
        dbursts.push_back(dburst);
        dburst.clear();
    }
    
    /* second is the Q matrix */
    
    double* qMatrix = mxGetPr(prhs[1]);
    int ncols = mxGetN(prhs[1]);
    int nrows = mxGetM(prhs[1]);
    if (ncols != nrows){
        delete qMatrix;
        mexErrMsgTxt ("Q-matrix is not square");    
    }

    DCProgs::t_rmatrix matrix(nrows ,ncols);
    
    for (int i=0; i<nrows; i++){
        for (int j=0;j<ncols;j++){
            matrix(i,j) = qMatrix[(i*ncols)+j];
        }
    }

    /* third is \tau, the resolution time (in seconds)*/
    double tau = mxGetScalar(prhs[2]);
     
    /* fourth is the t_Crit time */
    double t_crit = mxGetScalar(prhs[3]);
    
    /* fifth is the number of open states */
    int open_states = mxGetScalar(prhs[4]);
    

    DCProgs::Log10Likelihood likelihood(dbursts, open_states, tau, t_crit);
    
    DCProgs::t_rmatrix smatrix(5 ,5);
    smatrix << -3050,        50,  3000,      0,    0, 
            2./3., -(500+(2./3.)),     0,    500,    0,  
              15,         0, -2065,     50, 2000,  
                0,     15000,  4000, -19000,    0,  
                0,         0,    10,      0,  -10;

    DCProgs::t_real const result = likelihood(matrix);
    //mexPrintf("Computation 1: %.16f \n" ,result*log(10));
    
    //mex_test();
    /* return the result */
    
    plhs[0] = mxCreateDoubleScalar(result*log(10));

    
    
}

void mex_test() {
    
    DCProgs::t_Bursts bursts{
     {0.0010134001970291137},                  /* 1st burst */
     {0.00027620866894721984},                            /* 2nd burst */
     {0.0034364809524267915, 0.00010715194791555405, 0.0078944320753216741} /* 3rd burst */
    };
    
    
    // DCProgs::t_Bursts bursts{
    // {0.1, 0.2, 0.1},                  /* 1st burst */
    // {0.2},                            /* 2nd burst */
    // {0.15, 0.16, 0.18, 0.05, 0.1}     /* 3rd burst */
    //};
    
    
    
    DCProgs::Log10Likelihood likelihood(bursts, /*nopen=*/2, /*tau=*/0.0001, /*tcrit=*/0.004);
    
    DCProgs::t_rmatrix matrix(5 ,5);
    matrix << -3.05000000e+03, 5.00000000e+01, 3.00000000e+03, 0.00000000e+00, 0.00000000e+00, 
            6.66666667e-01,  -5.00666667e+02,   0.00000000e+00,   5.00000000e+02, 0.00000000e+00,  
               1.50000000e+01, 0.00000000e+00, -2.06500000e+03, 5.00000000e+01, 2.00000000e+03,  
                0.00000000e+00 , 1.50000000e+04, 4.00000000e+03, -1.90000000e+04,0.00000000e+00,  
                0.00000000e+00, 0.00000000e+00,  1.00000000e+01,  0.00000000e+00, -1.00000000e+01;

    DCProgs::t_real const result = likelihood(matrix);
    mexPrintf("Computation 1: %f \n" ,result*log(10));
     
}