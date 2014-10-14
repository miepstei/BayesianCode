#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include <iostream>
#include "limits.h"
#include "math.h"
#include <missed_eventsG.h>
#include <idealG.h>
#include <occupancies.h>
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 5){
        std::stringstream ss;
        ss << "calculates Equilibrium occupancies for Missed Events matricies" << std::endl;
        ss << "Five arguments expected - Q-matrix ,nopen, tau, isInitial, dcpOptions" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "tau - scalar double - resolution time" << std::endl;
        ss << "isInitial - scalar bool - initial (as opposed to final) vectors" << std::endl;
        ss << "options - cell array (1 x 6) - options for root finding" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    /* third is \tau, the resolution time (in seconds)*/
    double tau = mxGetScalar(prhs[2]);
    if (tau <= 0)
        mexErrMsgTxt ("tau is zero or negative");
    
   
    /* fourth is whether we want initial or closing vectors */
    bool isInitial = (bool)mxGetScalar(prhs[3]);
    
    /* options for dcprogs */
    if (! mxIsCell (prhs[4]))
        mexErrMsgTxt ("expects cell array of parameters for likelihood calculation");
    
    double likelihood_params [6];
    dcp_options(prhs[4],likelihood_params); 
    
    DCProgs::t_initvec occvec;
    
    int nmax = likelihood_params[0];
    double xtol = likelihood_params[1];
    double rtol = likelihood_params[2];
    int itermax = likelihood_params[3];
    double lower_bound = likelihood_params[4];
    double upper_bound = likelihood_params[5];    
    
    try { 
        // Create missed-events G
        DCProgs::MissedEventsG eG(qmatrix, tau, nmax, xtol, rtol, itermax,  lower_bound, upper_bound);   
        occvec = DCProgs::occupancies(eG,isInitial);
        
    } catch (std::exception& e) {
        mexPrintf(e.what());   
        mexErrMsgTxt("[WARN]: DCProgs - Error thrown in DCProgs::occupancies\n");
             
    }         
        
    /* assign results */
    
    int nopen = mxGetScalar(prhs[1]);
    int nclose = mxGetN(prhs[0]) - nopen;
    
    double  *pointer;
    mwSize index;
           
    if (isInitial) {
        /*return the vector 1 x nopen*/
        plhs[0] = mxCreateNumericMatrix(1,nopen, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nopen; index++ ) {
            pointer[index] = occvec[index];
        }
    } else {
        /*return the vector nclose x 1*/
        plhs[0] = mxCreateNumericMatrix(nclose,1, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nclose; index++ ) {
            pointer[index] = occvec[index];
        }            
    }
    
    return;
    
}