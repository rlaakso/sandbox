#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <omp.h>

#ifndef NO_MEX
#include "mex.h"
#endif

float conv_kernel(const float *frameptr, const float *kernelptr, int fw, int kw, int kh);
float conv_kernel_sse(const float *frameptr, const float *kernelptr, int fw, int kw, int kh);

/**
   Compute convolution for a single point, handling border cases with extend.
 **/
void conv_single(const float *frame, int fw, int fh, const float *kernel, int kw, int kh, float *out, int x, int y) {
  int p,q, offx = -kw/2, offy = -kh/2;
   float sum = 0;
   for (q = 0; q < kh; q++) {
      int ty = q + offy;
      int corry = y+ty;
      if (corry < 0) corry = 0;
      if (corry >= fh) corry = fh-1;

      for (p = 0; p < kw; p++) {
	 int tx = p + offx;	 
	 int corrx = x+tx;

	 if (corrx < 0) corrx = 0;
	 if (corrx >= fw) corrx = fw-1;

	 int soff = corrx + corry * fw;
	 sum += frame[soff] * kernel[p+q*kw];
      }
   }
   out[x+y*fw] = sum;
}


/**
   compute convolution for border areas, extending pixels where kernel would go out of frame 
**/
void conv_borders(const float *frame, int fw, int fh, const float *kernel, int kw, int kh, int sx, int sy, int nw, int nh, float *out) {
   int x, y;
   int kw2 = kw/2, kh2 = kh/2;

   /* borders - top, bottom, left, right */
   for (y = 0; y < kh2; y++) {
      if (y < sy || y >= sy+nh) continue;
      for (x = 0; x < fw; x++) {
	if (x < sx || x >= sx+nw) continue;
	conv_single(frame, fw, fh, kernel, kw, kh, out, x, y);
      }
   }
   for (y = fh-kh2; y < fh; y++) {
      if (y < sy || y >= sy+nh) continue;
      for (x = 0; x < fw; x++) {
	if (x < sx || x >= sx+nw) continue;
	conv_single(frame, fw, fh, kernel, kw, kh, out, x, y);
      }
   }
   for (y = 0; y < fh; y++) {
      if (y < sy || y >= sy+nh) continue;
      for (x = 0; x < kw2; x++) {
	if (x < sx || x >= sx+nw) continue;
	conv_single(frame, fw, fh, kernel, kw, kh, out, x, y);
      }
   }
   for (y = 0; y < fh; y++) {
      if (y < sy || y >= sy+nh) continue;
      for (x = fw-kw2; x < fw; x++) {
	if (x < sx || x >= sx+nw) continue;
	conv_single(frame, fw, fh, kernel, kw, kh, out, x, y);
      }
   }
}


void conv_interior(const float *frame, int fw, int fh, const float *kernel, int kw, int kh, int sx, int sy, int nw, int nh, float *out) {
   int x, y;
   int kw2 = kw/2, kh2 = kh/2;

   if (sx < kw2) sx = kw2;
   if (sx+nw > fw-kw2) nw = fw-kw2-sx;

   if (sy < kh2) sy = kh2;
   if (sy+nh > fh-kh2) nh = fh-kh2-sy;
   
   int can_use_sse = (kw&0x3) == 0;

   /* loop over interior of the image */
   #pragma omp parallel for
   for (y = sy; y < sy+nh; y++) { 
     for (x = sx; x < sx+nw; x++) {

       int offx = -kw/2, offy = -kh/2;
	int fx = x + offx;
	int fy = y + offy;

	/*	printf("conv: %d, %d (%d, %d -> %d, %d).\n", x, y, fx, fy, fx+kw, fy+kh); */

	 /* compute convolution for this output pixel */

	const float *start = &frame[fx+fy*fw];
	/*	printf("Frame start: %16lX, kernel: %16lX\n", start, kernel);*/
	
	if (!can_use_sse) {
	  out[x+y*fw] = conv_kernel(start, kernel, fw, kw, kh);
	} else {
	  out[x+y*fw] = conv_kernel_sse(start, kernel, fw, kw, kh);
	}
      }
   }
}


/**
   Compute convolution
 **/
void process(const float *frame, int fw, int fh, const float *kernel, int kw, int kh, int sx, int sy, int nw, int nh, float *out) {
  conv_borders(frame, fw, fh, kernel, kw, kh, sx, sy, nw, nh, out);
  conv_interior(frame, fw, fh, kernel, kw, kh, sx, sy, nw, nh, out);
}


#ifndef NO_MEX
int check_args(int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[])
{
   if(nrhs != 6) {
      mexErrMsgTxt("Usage: localconv(frame, kernel, startx, starty, width, height)");
   }

   if (!mxIsSingle(prhs[0]) || !mxIsSingle(prhs[1])) {
      mexErrMsgTxt("Arguments need to be of types single.");
   }

   int framew 	= mxGetM(prhs[0]);
   int frameh 	= mxGetN(prhs[0]);
  
   int kernelw = mxGetM(prhs[1]);
   int kernelh = mxGetN(prhs[1]);

   double startx = mxGetScalar(prhs[2]);
   double starty = mxGetScalar(prhs[3]);
   double width = mxGetScalar(prhs[4]);
   double height = mxGetScalar(prhs[5]);

   /* TODO FIXME do input validation */
   /*   mexPrintf("localconv: frame %d x %d, kernel %d x %d, start x,y %f, %f, w,h %f, %f.\n", 
	     framew, frameh, kernelw, kernelh, startx, starty, width, height);
   */
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[])
{
   check_args(nlhs, plhs, nrhs, prhs);

   /* assign input parameters */
   float *frame = (float *) mxGetPr(prhs[0]);
   int framew = mxGetM(prhs[0]);
   int frameh = mxGetN(prhs[0]);

   float *kernel =(float *) mxGetPr(prhs[1]);
   int kernelw = mxGetM(prhs[1]);
   int kernelh = mxGetN(prhs[1]);

   double startx = mxGetScalar(prhs[2]);
   double starty = mxGetScalar(prhs[3]);
   double width = mxGetScalar(prhs[4]);
   double height = mxGetScalar(prhs[5]);


   /* output matrix */
   plhs[0] = mxCreateNumericMatrix(framew, frameh, mxSINGLE_CLASS, mxREAL);
   float *output = (float*) mxGetPr(plhs[0]); 
   memset(output, 0, framew*frameh*sizeof(float));

   process(frame, framew, frameh, kernel, kernelw, kernelh, startx, starty, width, height, output);
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
   float *kernel = malloc(sizeof(float) * 48 * 48);
   for (y = 0; y < 48; y++) {
      for (x = 0; x < 48; x++) {
	 kernel[x+y*48] = x;
      }
   }

   //   printf("Frame: %16lX - %16lX, kernel: %16lX\n", img, img + (320*640*sizeof(float)), kernel);
   //   for (i = 0; i < 20; i++) {
        process(img, 640, 320, kernel, 48, 48, 0, 0, 640, 320, tmp);
	//process(img, 640, 320, kernel, 48, 48, 100, 100, 50, 50, tmp);
     //}

   free(kernel);
   free(tmp);
   free(img);

   printf("OK\n");
   return 0;
}

#endif
