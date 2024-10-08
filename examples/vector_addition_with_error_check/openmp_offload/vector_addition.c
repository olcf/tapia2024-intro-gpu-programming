#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

// Size of array
#define N 1048576


// Main program
int main()
{
    // Number of bytes to allocate for N doubles
    size_t bytes = N*sizeof(double);
    
    //declaring start_time and end_time
    double start_time, end_time;
    float elapsed_time;

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

    start_time = omp_get_wtime();
    //Summing arrays A and B for C
    #pragma omp target map(to:A[:N], B[:N]) map(from:  C[:N])
    #pragma omp  teams 
    for(int i=0; i<N; i++)
    {
	    C[i] = A[i] + B[i];
    }
    end_time = omp_get_wtime();
    elapsed_time = end_time - start_time;

    // Verify results
    double tolerance = 1.0e-14;
    for(int i=0; i<N; i++)
    {
        if( fabs(C[i] - 3.0) > tolerance )
        { 
            printf("Error: value of C[%d] = %f instead of 3.0\n", i, C[i]);
            exit(-1);
        }
    }	

    // Free CPU memory
    free(A);
    free(B);
    free(C);

    printf("\n---------------------------\n");
    printf("__SUCCESS__\n");
    printf("---------------------------\n");
    printf("N                 = %d\n", N);
    printf("---------------------------\n\n");
    printf("Elapsed Compute time      = %1.5f\n", elapsed_time);

    return 0;
}
