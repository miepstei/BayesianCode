#include "mex.h"
#include "matrix.h"
#include <math.h>
#include <algorithm>

void m_mult(double *A, double *B, int m,int n, int o, int p, double *out){
    //demonstration of matrix multiplication
    //A and B are 1-D  arrays
    
    int counter = 0;
    
    
    for (int i = 0; i < m; i++){
         for (int j =0; j < p; j++){
        
            
            for (int l = 0; l<n; l++){
                 int y = l+(n*i);
                 int x = j+(l*p);
                
                 out[counter] = out[counter] + (A[x] * B[y]);  
                 //cout << "icoord - " << x << " jcoord - " << y << " out = " << out[counter] << " -> " << A[x] << " * " << B[y] << endl;
            }
            //cout << endl << endl;
            counter++;
            
        }
    }  
}

bool compare (double i,double j)
{
  return (i>j);
}

double log_add(double elements[],int no_elems,double mxInf){
    
    double lm = 0;   
    
    /*we have to sort this array and do some magic
    for (int i=0;i<no_elems;i++){
        lm=lm+elements[i];
        mexPrintf("element %i = %f \n",i, elements[i]);
    }
     
    
    mexPrintf("\n\n");  
    */
    std::sort( elements, elements + no_elems, compare);
    ///mexPrintf("exp(-Inf) = %f \n",exp((-mxInf)-1));
    if (elements[0] == mxInf || (elements[0] == -mxInf && elements[no_elems-1] == -mxInf)){
        //mexErrMsgTxt("[WARN] - Element 0 is Inf!\n\n"); 
        lm=-mxInf;
    }
    else{
        //mexPrintf("Element 0 is %f\n\n",elements[0]); 
        double m_sum=0;
        for (int i=1;i<no_elems;i++){
            //mexPrintf("element 0 now = %f \n",i, elements[0]);
            //mexPrintf("element %i now = %f \n",i, elements[i]);
            m_sum=m_sum+exp(elements[i]-elements[0]);
            //mexPrintf("elements[i]-elements[0] = %f, exp=%f\n",elements[i]-elements[0],exp(elements[i]-elements[0]) );
            //mexPrintf("m_sum now = %f \n",m_sum);
        }
        lm=elements[0]+log(1+m_sum);
    }
    
    //mexPrintf("\n\n"); 
    return lm;
}


void l_mult(double *A, double *B, int m,int n, int o, int p,double mxInf, double *out){
    //where the magic happens
    //A and B are 1-D  arrays
    
    /*
    for (int z=0; z < o*p;z++){
        mexPrintf("element %z = %f \n",z, B[z]);
    }
    
    for (int z=0; z < m*n;z++){
        mexPrintf("matrix A element %i = %f \n",z, A[z]);
    }
    
    for (int z=0; z < o*p;z++){
        mexPrintf("matrix B element %i = %f \n",z, B[z]);
    }
    */
    
    int counter = 0;
    double elements[p];
    for (int j = 0; j < p; j++){
         for (int i =0; i < m; i++){
        
            
            for (int l = 0; l<n; l++){
                 
                 int x = i+(l*m);
                 int y = l+(j*o);
                 
                 elements[l] = A[x] + B[y];
                 //mexPrintf("x = %i, y = %i,element %i = %f + %f \n",x,y,l, A[x],B[y]);
                 
            }
            for (int i=0;i<n;i++){
                //mexPrintf("element %i = %f \n",i, elements[i]);
            }
            out[counter]=log_add(elements,n,mxInf);
            //mexPrintf("value at %i = %f \n",counter, out[counter]);
            counter++;
            
        }
    }  

}

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] ) {
    
    /* params */
    
    mxArray *mx_a;
    mxArray *mx_b;
    
    //A matrix (in logs)
    int m = mxGetM(prhs[0]);
    int n = mxGetN(prhs[0]);
    
    //B matrix (in logs)
    int o = mxGetM(prhs[1]);
    int p = mxGetN(prhs[1]);
    
    
    
    if(n != o)
        mexErrMsgTxt("Inner dimensions are not equal");
    
    int i = 0;
    
    double *A = mxGetPr(prhs[0]);
    mx_a = mxCreateDoubleMatrix(n, m, mxREAL);
    double *a_ptr = mxGetPr(mx_a);
    
    for (i = 0; i<m*n; i++) {
        a_ptr[i] = A[i];   
    }
    
    i = 0;    
   
    
    double *B = mxGetPr(prhs[1]);
    mx_b = mxCreateDoubleMatrix(o, p, mxREAL);
    double *b_ptr = mxGetPr(mx_b);
    
    for (i = 0; i<o*p; i++) {
        b_ptr[i] = B[i];   
    }
    
   
    
    /*logadd (mult) */
    plhs[0] = mxCreateDoubleMatrix(m, p, mxREAL);    
    double *out = mxGetPr(plhs[0]);
    double mxInf = mxGetInf();
    try {
        //m_mult(A,B,m,n,o,p,out);
        l_mult(A,B,m,n,o,p,mxInf,out);
        //mexPrintf("m - %i, n - %i, o - %i, p - %i",m,n,o,p);
    } catch (int a) {
        mexErrMsgTxt("Function exception");   
    }
    
    /*tillbaka */   
}