#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "idealG.h"
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 4){
        std::stringstream ss;
        ss << "calculates ideal X to Y transition exp(Q_XX * t) * Q_XY" << std::endl;
        ss << "Four arguments expected - Q-matrix ,nopen, t. isAF (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "t - scalar double - duration time" << std::endl;
        ss << "isAF - scalar bool - calculate exp(Q_AF * t) or exp(Q_FA * t)" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    double t = mxGetScalar(prhs[2]);
    if (t < 0)
        mexErrMsgTxt ("t cannot be negative");
    
    bool isAF = (bool)mxGetScalar(prhs[3]);
    
    DCProgs::t_rmatrix expT;
    try { 
        // Create missed-events G
       DCProgs::IdealG idealG(qmatrix);
        if (isAF)
            expT = idealG.af(t);
        else
            expT = idealG.fa(t);
        
    } catch (std::exception& e) {
        mexPrintf("[WARN]: DCProgs - Error thrown in DCProgs::IdealG\n");
        mexPrintf(e.what());        
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