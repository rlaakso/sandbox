#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <omp.h>

#ifndef NO_MEX
#include "mex.h"
#endif

void process(const float *frame, int fw, int fh, float *out) {
  int x,y,ptr=0;
  for (y = 0; y < fh; y++) {
    for (x = 0; x < fw; x++) {
      out[ptr] = -frame[ptr];
      ptr++;
    }
  }
}


#ifndef NO_MEX
int check_args(int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[])
{
   if(nrhs != 1) {
      mexErrMsgTxt("Usage: mexneg(frame)");
   }

   if (!mxIsSingle(prhs[0])) {
      mexErrMsgTxt("Argument needs to be of type single.");
   }

   int framew 	= mxGetM(prhs[0]);
   int frameh 	= mxGetN(prhs[0]);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[])
{
   check_args(nlhs, plhs, nrhs, prhs);

   float *frame = (float *) mxGetPr(prhs[0]);
   int framew = mxGetM(prhs[0]);
   int frameh = mxGetN(prhs[0]);

   /* output matrix */
   plhs[0] = mxCreateNumericMatrix(framew, frameh, mxSINGLE_CLASS, mxREAL);
   float *output = (float*) mxGetPr(plhs[0]); 
   memset(output, 0, framew*frameh*sizeof(float));

   process(frame, framew, frameh, output);
}

#else

int main() {
   int x,y,i;
   float *img = malloc(sizeof(float) * 320 * 640);
   float *tmp = malloc(sizeof(float) * 320 * 640);
   for (y = 0; y < 320; y++) {
      for (x = 0; x < 640; x++) {
	 img[x+y*640] = (x+y)&255;
      }
   }

   //for (i = 0; i < 20; i++) {
   //     process(img, 640, 320, kernel, 9, 18, 0, 0, 640, 320, tmp);
     process(img, 640, 320, tmp);
     //}

   free(tmp);
   free(img);

   printf("OK\n");
   return 0;
}

#endif
