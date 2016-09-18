COPTIMFLAGS := -O3 -msse4a

.phony: profile

all: localconv.mexa64 localconv_test mexneg.mexa64 mexneg_test convkernel_test

convkernel_asm.o: convkernel_asm.asm
	yasm -f elf64 convkernel_asm.asm -o convkernel_asm.o

localconv.mexa64: localconv.c convkernel_asm.o
	CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp"	/opt/Matlab/bin/mex localconv.c convkernel.c convkernel_asm.o

localconv_test: localconv.c convkernel.c convkernel_asm.o
	gcc -c $(COPTIMFLAGS) -fopenmp -DNO_MEX -g -Wall localconv.c convkernel.c
	gcc -fopenmp -o localconv_test localconv.o convkernel.o convkernel_asm.o

profile:
	rm -f callgrind.out.*
	valgrind --tool=callgrind --dump-instr=yes --trace-jump=yes ./localconv_test
	kcachegrind




mexneg.mexa64: mexneg.c
	CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp"	/opt/Matlab/bin/mex mexneg.c 

mexneg_test: mexneg.c
	gcc -DNO_MEX -g -o mexneg_test -Wall mexneg.c



convkernel_test: convkernel_test.c convkernel_asm.o convkernel.c
	gcc -c -DNO_MEX -g -Wall convkernel_test.c convkernel.c
	gcc -o convkernel_test convkernel_test.o convkernel_asm.o convkernel.o
