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
        ss << "Five arguments expected - Q-matrix ,nopen, s, isA, dcpOptions (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "tres = scalar double - resolution time" << std::endl;
        ss << "isA calculate for the A states (0 for F states)" << std::endl;
        ss << "options - cell array (1 x 6) - options for root finding" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    
    double tres = mxGetScalar(prhs[2]);
    if (tres < 0)
        mexErrMsgTxt ("tres cannot be negative");
    
    bool isAF = (bool)mxGetScalar(prhs[3]);
    
    /* options for dcprogs */
    if (! mxIsCell (prhs[4]))
        mexErrMsgTxt ("expects cell array of parameters for likelihood calculation");
    
    double likelihood_params [6];
    dcp_options(prhs[4],likelihood_params);
    
    
    std::vector<DCProgs::Root> roots;
    try { 
        // Create det|W(s)| 
        DCProgs::DeterminantEq detWs(qmatrix , tres);
        
        double xtol = likelihood_params[1];
        double rtol = likelihood_params[2];
        int itermax = likelihood_params[3];
        double lower_bound = likelihood_params[4];
        double upper_bound = likelihood_params[5];        
        
        if (isAF)
            roots = DCProgs::find_roots(detWs,xtol,rtol,itermax,lower_bound,upper_bound);
        else {
            DCProgs::DeterminantEq detWsT = detWs.transpose();
            roots = DCProgs::find_roots(detWsT,xtol,rtol,itermax,lower_bound,upper_bound);
        }
        
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
        /*return the matrix nopen x nopen */
        plhs[0] = mxCreateNumericMatrix(nopen,1, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for(DCProgs::Root const &root: roots) {
            pointer[index] = root.root;
            index++;
        } 
    } else {
        /*return the matrix nclose x nclose*/
        plhs[0] = mxCreateNumericMatrix(nclose,1, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for(DCProgs::Root const &root: roots) {
            pointer[index] = root.root;
            index++;
        }            
    }

    return;    
    
}