#include <gsl/gsl_matrix.h>
#include <gsl/gsl_linalg.h>
#include "mex.h"

#ifndef HS_H_INCLUDED
#define HS_H_INCLUDED
int f(int a);
gsl_matrix* calc_Hs(double s, double tres, double* Qxx, double* Qyy, double* Qxy, double* Qyx, int ky, int kx);
gsl_matrix* calc_Ws(double s, double tres, double* Qxx, double* Qyy, double* Qxy, double* Qyx, int ky, int kx);
double calc_detWs(double s, double tres, double* Qxx, double* Qyy, double* Qxy, double* Qyx, int ky, int kx);
gsl_matrix* setup_matrix(double *matrix_ptr,int rows,int cols);
#endif