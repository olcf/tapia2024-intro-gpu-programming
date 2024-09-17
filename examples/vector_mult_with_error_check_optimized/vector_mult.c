#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

// Size of array
#define N 25985


// Main program
int main()
{
    // Number of bytes to allocate for N doubles
    size_t bytes = N*sizeof(double);
    
    //declaring start_time and end_time
    double start_time, end_time;
    float elapsed_time;

    // Allocate memory for arrays A, B, and C on host
    double *A = (double*)malloc(N * N * sizeof(double));
    double *B = (double*)malloc(N * N * sizeof(double));
    double *C = (double*)malloc(N * N * sizeof(double));

  /* for (int i = 0; i < N; i++) 
   {
        A[i] = (double*)malloc(bytes);
        B[i] = (double*)malloc(bytes);
        C[i] = (double*)malloc(bytes);
    }*/

    // Fill host arrays A, B, and C
    for(int i=0; i<N; i++)
    {
	    for(int j=0; j<N; j++){
   
              A[i * N + j] = 1.0;
              B[i * N + j] = 2.0;
              C[i * N + j] = 0.0;
           }
    }
    //starting clock
    start_time = omp_get_wtime();

    //Summing arrays A and B for C
//   #pragma omp target map(to:A[:N*N], B[:N*N]) map(from:  C[:N*N])
//   #pragma omp teams distribute parallel for collapse(2) //default(shared) 
    for(int i=0; i<N; i++){
	    for(int j=0; j<N; j++) {
	       C[i * N + j] = A[i * N + j]  * B[i * N + j];
	    }
    }
    end_time = omp_get_wtime();
    elapsed_time = end_time - start_time;

    // Verify results
    double tolerance = 1.0e-14;
    for(int i=0; i<N; i++)
    {
	    for(int j=0; j<N; j++)
	    {
              if( fabs(C[i * N + j] - 2.0) > tolerance )
               { 
                  printf("Error: value of C[%d][%d] = %f instead of 2.0\n", i,j, C[i * N + j]);
                 exit(-1);
               }
           }
    }


    // Free CPU memory
    /* for (int i = 0; i < N; i++) {
        free(A[i]);
        free(B[i]);
        free(C[i]);
    }*/

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
