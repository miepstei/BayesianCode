#include "mex.h"
#include "likelihood.h"

/*
 *  takes a pointer to a mxArray (qmatrix), pointer to a mxArray (open states)
 *  returns a DCProgs qmatrix
*/
DCProgs::QMatrix mex_q(const mxArray * matMatrix,const mxArray * nopen) {
    
    /* parse q-matrix */
    double* mexMatrix = mxGetPr(matMatrix);
    int ncols = mxGetN(matMatrix);
    int nrows = mxGetM(matMatrix);
    if (ncols != nrows){
        delete mexMatrix;
        mexErrMsgTxt ("Q-matrix is not square");    
    }

    DCProgs::t_rmatrix matrix(nrows ,ncols);
    
    //matlab uses column-major notation so the 1-d array iterates down the column first
    
    for (int i=0; i<nrows; i++){
        for (int j=0;j<ncols;j++){
            matrix(i,j) = mexMatrix[(j*nrows)+i];
        }
    }    
    return DCProgs::QMatrix(matrix, mxGetScalar(nopen));
}

void dcp_options(const mxArray * dcp_options_cell, double * likelihood_params) {
    int ncols = mxGetN(dcp_options_cell);
    int nrows = mxGetM(dcp_options_cell);
    
    if (ncols < nrows || nrows != 1 || ncols != 6){
        mexPrintf ("%i %i \n",ncols,nrows);
        mexErrMsgTxt ("options array should be 1*6");   
    }
    
    for (int i = 0; i < ncols; i++) {
        mxArray* mopts = mxGetCell (dcp_options_cell, i);
        double *options = mxGetPr(mopts);
        likelihood_params[i] = options[0];
    }    
    
}