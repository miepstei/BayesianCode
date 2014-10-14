#include "mex.h"
#include <stdio.h>
#include <vector>
#include "likelihood.h"
#include "missed_eventsG.h"
#include "asymptotes.h"
#include "dcpUtils.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* error handling */
    
    if (nrhs != 6){
        std::stringstream ss;
        ss << "calculates aymptotic probability of survival in X states before transition" << std::endl;
        ss << "Six arguments expected - Q-matrix ,nopen, t, isA, dcp_options (" << nrhs << " received)" << std::endl;
        ss << "Q-matrix - k x k matrix double - the Q matrix" << std::endl;
        ss << "nopen - scalar int - number of open states in mechanism" << std::endl;
        ss << "tres = scalar double - resolution time" << std::endl;
        ss << "i - scalar int - the ith exponent and matrix to return" << std::endl;
        ss << "isA - scalar bool - calculate probability of no F times detected between 0 and t (and vice versa)" << std::endl;
        ss << "options - cell array (1 x 6) - options for root finding" << std::endl;
        mexErrMsgTxt (ss.str().c_str());
    }    
    
    int nopen = mxGetScalar(prhs[1]);
    int nclose = mxGetN(prhs[0]) - nopen;
    
    /* create Q-matrix */
    DCProgs::QMatrix qmatrix = mex_q(prhs[0],prhs[1]);
    
    double tres = mxGetScalar(prhs[2]);
    if (tres < 0)
        mexErrMsgTxt ("tres cannot be negative");
    
    int ith = (int)mxGetScalar(prhs[3]);
    bool isAF = (bool)mxGetScalar(prhs[4]);
    
    if (ith < 0 || (isAF && ith >= nopen) || (!isAF && ith >= nclose))
        mexErrMsgTxt ("ith cannot be negative or out of range for component");    
    
    /* options for dcprogs */
    if (! mxIsCell (prhs[5]))
        mexErrMsgTxt ("expects cell array of parameters for likelihood calculation");
    
    double likelihood_params [6];
    //parse rootfinding options
    dcp_options(prhs[5],likelihood_params);

    DCProgs::Asymptotes::t_MatrixAndRoot component;
    DCProgs::t_real root;
    DCProgs::t_rmatrix ARi;
    try { 
        // Create survivor object A_S - ignore first parameter for rootfinding
        double xtol = likelihood_params[1];
        double rtol = likelihood_params[2];
        int itermax = likelihood_params[3];
        double lower_bound = likelihood_params[4];
        double upper_bound = likelihood_params[5];    
        
        /* This is how to find roots and create survivor function explicitly
        
        DCProgs::DeterminantEq detWs(qmatrix , tres);
        std::vector<DCProgs::Root> open_roots;
        open_roots = DCProgs::find_roots(detWs,xtol,rtol,itermax,lower_bound,upper_bound);
        
        DCProgs::DeterminantEq detWsT = detWs.transpose();
        std::vector<DCProgs::Root> shut_roots;
        shut_roots = DCProgs::find_roots(detWsT,xtol,rtol,itermax,lower_bound,upper_bound);
         
        */
        
        DCProgs::ApproxSurvivor survivor(qmatrix , tres, xtol, rtol, itermax,  lower_bound, upper_bound);
        
        if (isAF){
            ARi = std::get<0>(survivor.get_af_components(ith));
            root = std::get<1>(survivor.get_af_components(ith));
        }
        else {
            ARi = std::get<0>(survivor.get_fa_components(ith));
            root = std::get<1>(survivor.get_fa_components(ith));            
        }
        
    } catch (std::exception& e) {
        mexPrintf(e.what()); 
        mexErrMsgTxt("[WARN]: DCProgs - Error thrown in DCProgs::AsymptoticSurvivor (Exponent)\n");
               
    } 
    
    /* return the results */
     
    double  *pointer;
    mwSize index;
           
    if (isAF) {
        //return the matrix nopen x nopen for the ith component
        plhs[0] = mxCreateNumericMatrix(nopen,nopen, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nopen*nopen; index++ ) {
            pointer[index] = ARi(index);
        }
        plhs[1] = mxCreateDoubleScalar(root);
        
        
    } else {
        //return the matrix nclose x nclose
        plhs[0] = mxCreateNumericMatrix(nclose,nclose, mxDOUBLE_CLASS,mxREAL);
        pointer = mxGetPr(plhs[0]); 
        for ( index = 0; index < nclose*nclose; index++ ) {
            pointer[index] = ARi(index);
        }
        plhs[1] = mxCreateDoubleScalar(root);           
    }
    
    
    return;    
    
}