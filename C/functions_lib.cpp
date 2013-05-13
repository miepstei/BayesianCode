#include "functions_lib.h"
#include "mex.h"
#include <gsl/gsl_blas.h>
int f(int a){ return a + 1; }

gsl_matrix* setup_matrix(double *matrix, int rows, int cols){
    /* convenience function for setting up a gsl_matrix from a C++ matrix  */ 
    gsl_matrix *representation = gsl_matrix_alloc(rows,cols);
    
    for (int i=0;i<rows;i++){
        for (int j=0;j<cols;j++){
            gsl_matrix_set(representation,i,j,matrix[(j*rows)+i]);
        }   
    }

    return representation;  
}

double calc_detWs(double s, double tres, double* Qxx_m, double* Qyy_m, double* Qxy_m, double* Qyx_m, int kx, int ky){

    int sc;
    double result;
    
    gsl_matrix* Ws = calc_Ws(s,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m,kx,ky);
    gsl_permutation * p = gsl_permutation_alloc (kx);
    gsl_linalg_LU_decomp(Ws, p, &sc);
    result = gsl_linalg_LU_det(Ws, sc);
    
    //cleanup
    gsl_permutation_free(p);
    gsl_matrix_free(Ws);
    
    return result;
}

gsl_matrix* calc_Ws(double s, double tres, double* Qxx_m, double* Qyy_m, double* Qxy_m, double* Qyx_m, int kx, int ky){
   

   gsl_matrix *ws;
   ws=gsl_matrix_alloc(kx,kx); 
   gsl_matrix_set_identity(ws);
   gsl_matrix_scale(ws,s);
       
   //Calculate H(s)
   gsl_matrix *hs = calc_Hs(s,tres,Qxx_m,Qyy_m,Qxy_m,Qyx_m, kx, ky);
   gsl_matrix_sub(ws,hs);
   
   //cleanup
   gsl_matrix_free(hs); 
   return ws;
    
    
}

gsl_matrix* calc_Hs(double s, double tres, double* Qxx_m, double* Qyy_m, double* Qxy_m, double* Qyx_m, int kx, int ky) {
    
    /*
     *
     *
     *     *H(s)
     *I=eye(ky); 
     *expMat=mat_exp(-(s*I-Qyy)*tres); 
     *Hxx_s=Qxx+(Qxy*(s*I-Qyy)^-1)*(I-expMat)*Qyx; 
     *
    */
    
       /* Initialise Qxx,Qxy,Qyx,Qyy  */
   
    gsl_matrix *Qxx=setup_matrix(Qxx_m,kx,kx);
    gsl_matrix *Qxy=setup_matrix(Qxy_m,kx,ky);
    gsl_matrix *Qyx=setup_matrix(Qyx_m,ky,kx);
    gsl_matrix *Qyy=setup_matrix(Qyy_m,ky,ky);
    
    
    gsl_matrix *ky_eye; //identitny matrix of dimension ky,ky
    gsl_matrix *e_eye; //to hold the matrix exponential expMat
    gsl_matrix *detected_tres; //matrix representing period in states y for tres followed by transition to x
    gsl_matrix *seye2;
    gsl_matrix *inv_sI_Qyy;
    gsl_matrix *res;
    gsl_matrix *res2;
    gsl_matrix *res3;
    gsl_matrix *eye3;
    //printf("\tAllocate memory for the matrices\n");
    
    //allocate memory for all the matrices
    
    ky_eye=gsl_matrix_alloc(ky,ky);
    e_eye=gsl_matrix_alloc(ky,ky);
    seye2=gsl_matrix_alloc(ky,ky);
    detected_tres=gsl_matrix_alloc(ky,ky);
    inv_sI_Qyy=gsl_matrix_alloc(ky,ky);
    res=gsl_matrix_alloc(kx,ky);
    res2=gsl_matrix_alloc(ky,kx);
    res3 = gsl_matrix_alloc(kx,kx);
    eye3=gsl_matrix_alloc(ky,ky);
    
    //printf("\tAllocated memory for the matrices\n");
    
    gsl_matrix_set_identity(ky_eye); 
    //exp(-(s*I-Qyy)*tres)
    //build from the identity matrix
    gsl_matrix_memcpy (detected_tres,ky_eye);
    gsl_matrix_scale(detected_tres,s);
    gsl_matrix_sub(detected_tres,Qyy);
    gsl_matrix_scale(detected_tres,-1);
    gsl_matrix_scale(detected_tres,tres);
    gsl_linalg_exponential_ss(detected_tres, e_eye, .01);
    
    //printf("\tCalculated exp(-(s*I-Qyy)*tres)\n");
    
   
    //(s*I-Qyy)             
    gsl_matrix_memcpy (seye2,ky_eye);    
    gsl_matrix_scale(seye2,s);
    gsl_matrix_sub(seye2,Qyy);
    
    //printf("\tCalculated s*I-Qyy\n");
    
    //invert s*I-Qyy
    int sc;    
    gsl_permutation * p = gsl_permutation_alloc (ky);
    gsl_linalg_LU_decomp(seye2, p, &sc); 
    gsl_linalg_LU_invert(seye2, p, inv_sI_Qyy);
    gsl_permutation_free(p);
    
    //printf("\tInverted s*I-Qyy\n");
    
    /*
    for (int i=0; i<ky; i++){
        for (int j=0; j<ky; j++){
            mexPrintf("\t%f",gsl_matrix_get(inv_sI_Qyy,i,j));
        }
        mexPrintf("\n");
    }
    */
    
    //multiply Qxy * (s*I-Qyy)^-1
    gsl_matrix_set_zero(res);
    // res = (Qxy*(s*I-Qyy)^-1)
    gsl_blas_dgemm (CblasNoTrans, CblasNoTrans,
                  1.0, Qxy, inv_sI_Qyy,
                  0.0, res);
    

    
    //printf("\tCalculated Qxy * (s*I-Qyy)^-1\n");
    
    //res2 =(I-expMat)*Qyx;
    gsl_matrix_set_zero(res2);   
    gsl_matrix_memcpy (eye3,ky_eye);
    //printf("\tMemcpy (I-expMat)\n");
    gsl_matrix_sub(eye3,e_eye);
    
    //printf("\tSubtract (I-expMat)\n");
    
    gsl_blas_dgemm (CblasNoTrans, CblasNoTrans,
                  1.0, eye3, Qyx,
                  0.0, res2);
    
    //res3 = (Qxy*(s*I-Qyy)^-1)*(I-expMat)*Qyx;
    //res3 = res *res2
    //res3 is the result we want to return
    //printf("\t (I-expMat)*Qyx\n");
    
    gsl_matrix_set_zero(res3);
    gsl_blas_dgemm (CblasNoTrans, CblasNoTrans,
                  1.0, res, res2,
                  0.0, res3);
    
    
    gsl_matrix_add(res3,Qxx);
    
    /*
    for (int i=0; i<kx; i++){
        for (int j=0; j<kx; j++){
            mexPrintf("\t%f",gsl_matrix_get(res3,i,j));
        }
        mexPrintf("\n");
    }
     */
    
    //printf("\t Calced H(s)\n");
    
    //cleanup
    gsl_matrix_free(Qxx);
    gsl_matrix_free(Qxy);
    gsl_matrix_free(Qyx);
    gsl_matrix_free(Qyy);
    gsl_matrix_free(ky_eye);
    gsl_matrix_free(e_eye);
    gsl_matrix_free(detected_tres);
    gsl_matrix_free(seye2);
    gsl_matrix_free(inv_sI_Qyy);
    gsl_matrix_free(res);
    gsl_matrix_free(res2);
    gsl_matrix_free(eye3);
    
    //printf("\t Cleaned up H(s)\n");
    
    return res3;
}