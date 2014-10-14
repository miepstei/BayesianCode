#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "dcpUtils.h"
#include <iostream>
#include "limits.h"
#include "math.h"


using namespace std;
void mex_test();

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    /* params */
    
    /* first is the array of burst intervals
     needs to be parsed into a vector of vectors*/
    
    if (nrhs != 7)
        mexErrMsgTxt ("Seven arguments expected - bursts,Q-matrix,tau,tcrit,open_states,useChs,options");
    
    if (! mxIsCell (prhs[0]))
        mexErrMsgTxt ("expects cell array of burst intervals");
    
    DCProgs::t_Bursts dbursts;
    
    int n = mxGetNumberOfElements (prhs[0]);
    double burst_time = 0;
    for (int i = 0; i < n; i++) {
        mxArray* mburst = mxGetCell (prhs[0], i);
        
        int ncols = mxGetN(mburst);
        int nrows = mxGetM(mburst);
        
       
        if (ncols < nrows || nrows != 1){
            mxFree(mburst);
            mexErrMsgTxt ("burst array should be 1*n");   
        } 
        
        double *elements = mxGetPr(mburst);
        DCProgs::t_Burst dburst;       
        for (int j=0; j < ncols; j++){
            dburst.push_back(elements[j]);
            burst_time+=elements[j];
        }
        dbursts.push_back(dburst);
        dburst.clear();
    }
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[1],prhs[4]);
    
    /* third is \tau, the resolution time (in seconds)*/
    double tau = mxGetScalar(prhs[2]);
    
    /* fourth is the t_Crit time */
    double t_crit = mxGetScalar(prhs[3]);
    
    /* fifth is the number of open states */
    int open_states = mxGetScalar(prhs[4]);
    
    /*sixth is whether to use CHS vectors*/
    int useChs = mxGetScalar(prhs[5]);

    /* options for dcprogs */
    if (! mxIsCell (prhs[6]))
        mexErrMsgTxt ("expects cell array of parameters for likelihood calculation");
    
    double likelihood_params [6];
    //parse rootfinding options
    dcp_options(prhs[6],likelihood_params);
    
    int nmax = (int)likelihood_params[0];
    double xtol = likelihood_params[1];
    double rtol = likelihood_params[2];
    int itermax = (int)likelihood_params[3];
    double lower_bound = likelihood_params[4];
    double upper_bound = likelihood_params[5];    

    int error = 0;
    DCProgs::t_real result;
    
    try {
        
        if (useChs){
            DCProgs::Log10Likelihood likelihood(dbursts, open_states, tau, t_crit,nmax,xtol,rtol,itermax,lower_bound,upper_bound);
            result = likelihood(qmatrix);
        }
        else {
            DCProgs::Log10Likelihood likelihood(dbursts, open_states, tau, -t_crit,nmax,xtol,rtol,itermax,lower_bound,upper_bound);
            result = likelihood(qmatrix);
        }
    }
    
    catch (std::exception& e) {
        
        mexPrintf("[WARN]: DCProgs - Error thrown in DCProgs\n");
        mexPrintf(e.what());
        error = 1;
        plhs[0] = mxCreateDoubleScalar(0); /*set likelihood to zero*/
        plhs[1] = mxCreateDoubleScalar(error);
        return;
    }

    if (fabs(result) == std::numeric_limits<double>::infinity() || std::isnan(result)){
        mexPrintf("[WARN]: DCProgs - Likelihood NaN or Inf -> set to 0\n");
        result = 0;
        error = 1;
    }    
       
    plhs[0] = mxCreateDoubleScalar(result*log(10));
    plhs[1] = mxCreateDoubleScalar(error);
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