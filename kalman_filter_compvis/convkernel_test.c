#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

float conv_kernel(const float *frameptr, const float *kernelptr, int fw, int kw, int kh);

float conv_kernel_sse(const float *frameptr, const float *kernelptr, int fw, int kw, int kh);


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

   float out = 0.0f;

   clock_t tic = clock();
   int N = 1000 * 1000;
   for(i = 0; i < N; i++) {
     out = conv_kernel(&img[100+100*640], kernel, 640, 48, 48);
   }
   clock_t toc = clock();
   printf("C version, out: %f, time spent %f sec for %d ops\n", out, (double)(toc - tic) / CLOCKS_PER_SEC, N);

   out = 0.0f;

   tic = clock();
   for(i = 0; i < N; i++) {
     out = conv_kernel_sse(&img[100+100*640], kernel, 640, 48, 48);
   }
   toc = clock();
   printf("SSE version, out: %f, time spent %f sec for %d ops\n", out, (double)(toc - tic) / CLOCKS_PER_SEC, N);

   free(kernel);
   free(tmp);
   free(img);

   printf("OK\n");
   return 0;

}
