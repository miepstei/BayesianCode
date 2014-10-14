#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "missed_eventsG.h"
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 6){
        std::stringstream ss;
        ss << "calculates missed events X to Y transition exp(Q_XX * t) * Q_XY" << std::endl;
        ss << "Six arguments expected - Q-matrix ,nopen, t. isAF, dcpOptions (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "t - scalar double - duration time" << std::endl;
        ss << "tres = scalar double - resolution time" << std::endl;
        ss << "isAF - scalar bool - calculate exp(Q_AF * t) or exp(Q_FA * t)" << std::endl;
        ss << "options - cell array (1 x 6) - options for root finding" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    double t = mxGetScalar(prhs[2]);
    if (t < 0)
        mexErrMsgTxt ("t cannot be negative");
    
    double tres = mxGetScalar(prhs[3]);
    if (tres < 0)
        mexErrMsgTxt ("tres cannot be negative");
    
    bool isAF = (bool)mxGetScalar(prhs[4]);
    
    /* options for dcprogs */
    if (! mxIsCell (prhs[5]))
        mexErrMsgTxt ("expects cell array of parameters for likelihood calculation");
    
    double likelihood_params [6];
    dcp_options(prhs[5],likelihood_params);
    
    DCProgs::t_rmatrix expT;
    try { 
        // Create missed-events G
        int nmax = likelihood_params[0];
        double xtol = likelihood_params[1];
        double rtol = likelihood_params[2];
        int itermax = likelihood_params[3];
        double lower_bound = likelihood_params[4];
        double upper_bound = likelihood_params[5];     
        
        DCProgs::MissedEventsG missedEventsG(qmatrix, tres, nmax, xtol, rtol, itermax,  lower_bound, upper_bound);
        if (isAF)
            expT = missedEventsG.af(t);
        else
            expT = missedEventsG.fa(t);
        
    } catch (std::exception& e) {
        mexPrintf(e.what()); 
        mexErrMsgTxt("[WARN]: DCProgs - Error thrown in DCProgs::MissedEventsG\n");
    } 
    
    /* return the results */
     
    int nopen = mxGetScalar(prhs[1]);
    int nclose = mxGetN(prhs[0]) - nopen;
    
    double  *pointer;
    mwSize index;
           
    if (isAF) {
        /*return the vector nopen x nclose */
        plhs[0] = mxCreateNumericMatrix(nopen,nclose, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nopen*nclose; index++ ) {
            pointer[index] = expT(index);
        }
    } else {
        /*return the vector nclose x nopen*/
        plhs[0] = mxCreateNumericMatrix(nclose,nopen, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nopen*nclose; index++ ) {
            pointer[index] = expT(index);
        }            
    }
    
    return;    
    
}