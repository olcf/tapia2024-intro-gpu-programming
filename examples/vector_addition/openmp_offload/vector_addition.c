#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Size of array
#define N 1048576

// Main program
int main()
{
    // Number of bytes to allocate for N doubles
    size_t bytes = N*sizeof(double);

    // Allocate memory for arrays A, B, and C on host
    double *A = (double*)malloc(bytes);
    double *B = (double*)malloc(bytes);
    double *C = (double*)malloc(bytes);

   

    // Fill host arrays A, B, and C
    for(int i=0; i<N; i++)
    {
        A[i] = 1.0;
        B[i] = 2.0;
        C[i] = 0.0;
    }

    //Summing arrays A and B for C
    #pragma omp target map(to:A[:N], B[:N]) map(from:  C[:N])
    #pragma omp parallel for
    for(int i=0; i<N; i++)
    {
	    C[i] = A[i] + B[i];
    }


    // Free CPU memory
    free(A);
    free(B);
    free(C);

    printf("\n--------------------------- =%d\n",bytes);
    printf("__SUCCESS__\n");
    printf("---------------------------\n");
    printf("N                 = %d\n", N);
    printf("---------------------------\n");

    return 0;
vector_addition.f90}
