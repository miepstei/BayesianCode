#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "missed_eventsG.h"
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 5){
        std::stringstream ss;
        ss << "calculates derivative wrt s of sI-H(s)" << std::endl;
        ss << "Five arguments expected - Q-matrix ,nopen, s, isA (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "s - scalar double - Laplacian frequency s" << std::endl;
        ss << "tres = scalar double - resolution time" << std::endl;
        ss << "isA calculate for the A states (0 for F states)" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    double s = mxGetScalar(prhs[2]);
    
    double tres = mxGetScalar(prhs[3]);
    if (tres < 0)
        mexErrMsgTxt ("tres cannot be negative");
    
    bool isAF = (bool)mxGetScalar(prhs[4]);
    
    DCProgs::t_rmatrix det;
    try { 
        // Create det|W(s)| 
        DCProgs::DeterminantEq detWs(qmatrix , tres);
        if (isAF)
            det = detWs.s_derivative(s);
        else {
            DCProgs::DeterminantEq detWsT = detWs.transpose();
            det = detWsT.s_derivative(s);
        }
        
    } catch (std::exception& e) {
        mexPrintf("[WARN]: DCProgs - Error thrown in DCProgs::MissedEventsG\n");
        mexPrintf(e.what());        
    } 
    
    /* return the results */
     
    int nopen = mxGetScalar(prhs[1]);
    int nclose = mxGetN(prhs[0]) - nopen;
    
    double  *pointer;
    mwSize index;
           
    if (isAF) {
        /*return the matrix nopen x nopen */
        plhs[0] = mxCreateNumericMatrix(nopen,nopen, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nopen*nopen; index++ ) {
            pointer[index] = det(index);
        }
    } else {
        /*return the matrix nclose x nclose*/
        plhs[0] = mxCreateNumericMatrix(nclose,nclose, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nclose*nclose; index++ ) {
            pointer[index] = det(index);
        }            
    }

    return;    
    
}