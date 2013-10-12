#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <dlfcn.h>
#include "engine.h"

typedef void (*mexFunction_t)(int nargout, mxArray *pargout [ ], int nargin, const mxArray *pargin[]);

int main(int argc, const char *argv[])

{
  Engine *ep;
  char buff[1024];
  int i;

  /* matlab must be in the PATH! */
  if (!(ep = engOpen("matlab -nodisplay"))) {
    fprintf(stderr, "Can't start MATLAB engine\n");
    return -1;
  }
  engOutputBuffer(ep, buff, 1023);

  /* load the mex file */
  if(argc<2){
    fprintf(stderr, "Error. Give full path to the MEX file as input parameter.\n");
    return -1;
  }
  void *handle = dlopen(argv[1], RTLD_NOW);
  if(!handle){
    fprintf(stderr, "Error loading MEX file: %s\n", strerror(errno));
    return -1;
  }

  /* grab mexFunction handle */
  mexFunction_t mexfunction = (mexFunction_t)dlsym(handle, "mexFunction");
  if(!mexfunction){
    fprintf(stderr, "MEX file does not contain mexFunction\n");
    return -1;
  }

  /* load input data - for convenience do that using MATLAB engine */
  /* NOTE: parameters are MEX-file specific, so one has to modify this*/
  /* to fit particular needs */
  engEvalString(ep, "load ../Testing/valgrind_Ws_mex.mat");
  mxArray *arg1 = engGetVariable(ep, "root");
  mxArray *arg2 = engGetVariable(ep, "tres");
  mxArray *arg3 = engGetVariable(ep, "Qxx");
  mxArray *arg4 = engGetVariable(ep, "Qyy");
  mxArray *arg5 = engGetVariable(ep, "Qxy");
  mxArray *arg6 = engGetVariable(ep, "Qyx");
  mxArray *arg7 = engGetVariable(ep, "kx");
  mxArray *arg8 = engGetVariable(ep, "ky");
  mxArray *pargout[1] = {0};
  const mxArray *pargin[8] = {arg1, arg2,arg3, arg4,arg5, arg6,arg7, arg8};

  /* execute the mex function */
  mexfunction(1, pargout, 8, pargin);

  /* print the results using MATLAB engine */
  engPutVariable(ep, "result", pargout[0]);
  engEvalString(ep, "result");
  printf("%s\n", buff);

  /* cleanup */
  mxDestroyArray(pargout[0]);
  engEvalString(ep, "clear all;");
  dlclose(handle);
  engClose(ep);

  return 0;
}