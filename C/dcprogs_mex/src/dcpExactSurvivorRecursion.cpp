#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "missed_eventsG.h"
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 7){
        std::stringstream ss;
        ss << "calculates exact survivor of X states before transition to Y" << std::endl;
        ss << "Five arguments expected - Q-matrix ,nopen, t, isA (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "tres = scalar double - resolution time" << std::endl;
        ss << "isA - scalar bool - calculate probability of no F times detected between 0 and t (and vice versa)" << std::endl;
        ss << "i - scalar int - index for recursive matricies (eigenvalues)" << std::endl;
        ss << "m - scalar int - index" << std::endl;
        ss << "r - scalar int - index" << std::endl;
                
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    
    double tres = mxGetScalar(prhs[2]);
    if (tres < 0)
        mexErrMsgTxt ("tres cannot be negative");
    
    bool isAF = (bool)mxGetScalar(prhs[3]);
    
    int i = (int)mxGetScalar(prhs[4]);
    
    if (i < 0 || i >= qmatrix.nopen + qmatrix.nshut())
        mexErrMsgTxt ("i cannot be negative or greater than the number of rows/cols of Q");
    
    int m = (int)mxGetScalar(prhs[5]);
    if( m < 0 )
        mexErrMsgTxt ("m cannot be negative");  
    
    int r = (int)mxGetScalar(prhs[6]);
    if (r < 0)
        mexErrMsgTxt ("r cannot be negative");  
    
    DCProgs::t_rmatrix PSurvive;
    try { 
        // Create survivor object A_S
        DCProgs::ExactSurvivor survivor(qmatrix , tres);
        if (isAF){
            PSurvive = survivor.recursion_af(i, m, r);
        }
        else
            PSurvive = survivor.recursion_fa(i, m, r);
        
    } catch (std::exception& e) {
        mexPrintf("[WARN]: DCProgs - Error thrown in DCProgs::ExactSurvivor (recursion)\n");
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
            pointer[index] = PSurvive(index);
        }
    } else {
        /*return the matrix nclose x nclose*/
        plhs[0] = mxCreateNumericMatrix(nclose,nclose, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nclose*nclose; index++ ) {
            pointer[index] = PSurvive(index);
        }            
    }
    
    return;    
    
}