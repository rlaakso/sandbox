	bits 64
	default rel
	section .text

	global conv_kernel_sse

	;;conv_kernel - inner loop of convolution for a single pixel
	;;
	;; in:
	;; const float *frameptr - rdi
	;; const float *kernelptr - rsi
	;; int fw - rdx
	;; int kw - rcx
	;; int kh - r8
	;;
	;; out:
	;; convolution sum - xmm0
	;;
	
;;; 	float conv_kernel(const float *frameptr, const float *kernelptr, int fw, int kw, int kh) 

;;;   int p,q;
;;;   float sum = 0;
;;;   for (q = 0; q < kh; q++) {
;;;     for (p = 0; p < kw; p++) {
;;;       sum += *frameptr++ * *kernelptr++;
;;;     }
;;;     /* move image pointer to beginning of next line */
;;;     frameptr += fw - kw;
;;;   }

	
conv_kernel_sse:	
        xorps  xmm1,xmm1

	;; kh == 0 ?
        test   r8, r8
       	jz     end

	;; kw == 0 ?
        test   rcx, rcx
        jz     end

	;; test kernel width is multiple of 4
	mov	rax, rcx
	and	rax, 0xFFFFFC
	cmp	rax, rcx
	jne	kernel_width_error
	
	
	;; fw - kw
        sub    rdx,rcx		; in pixels
	shl    rdx, 2 		; in bytes

	;; sum = 0
        xorps  xmm0,xmm0
	
	;; y = 0
        xor    r9, r9
	
loop_y:
	;; x = 0
        xor    rax, rax
	

loop_x:
	;; xmm1 = *frameptr
       	movups  xmm1, [rdi]
	;; xmm0 = *kernelptr
	movaps  xmm2, [rsi]
	;; frameptr++
	add	rdi, 16
	;; kernelptr++
	add	rsi, 16
	;; xmm1 = xmm1 dot xmm2
	dpps	xmm1, xmm2, 0xF1
	;; xmm0 += xmm1
	addss	xmm0, xmm1

	;; x+=4
       	add	rax, 4
	
	;; x<kw ?
        cmp     rax, rcx
        jl     loop_x

	;; frameptr += fw - kw
        add    rdi, rdx

	;; y++
	inc	r9
        cmp    	r9, r8
        jl     loop_y

end:	
        ret
	
kernel_width_error:
	movss	xmm0, [minusone]
	ret

minusone:
	dd	-1.00e0
	