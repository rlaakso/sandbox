float conv_kernel(const float *frameptr, const float *kernelptr, int fw, int kw, int kh) {
  int p,q;
  float sum = 0;
  for (q = 0; q < kh; q++) {
    for (p = 0; p < kw; p++) {
      sum += *frameptr++ * *kernelptr++;
    }
    /* move image pointer to beginning of next line */
    frameptr += fw - kw;
  }
  return sum;
}
