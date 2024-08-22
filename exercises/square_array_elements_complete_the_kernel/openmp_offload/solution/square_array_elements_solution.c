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
    double *A_squared = (double*)malloc(bytes);
       

    // Initializing the Arrays A and A_squared
    for(int i=0; i<N; i++)
    {
        A[i] = (double)i;
        A_squared[i] = 0.0;
    }

    //Squaring array A for A_squared
    #pragma omp target map(to:A[:N]) map(from:  A_squared[:N])
    #pragma omp parallel for
    for(int i=0; i<N; i++)
    {
	    A_squared[i] = A[i] * A[i];
    }


    // Verify results
    double tolerance = 1.0e-14;
    for(int i=0; i<N; i++)
    {
        if( fabs((A_squared[i] - A[i] * A[i])) > tolerance )
        { 
            printf("Error: value of A_squared[%d] = %f instead of 2.0\n", i, A_squared[i]);
            exit(-1);
        }
    }	

    // Free CPU memory
    free(A);
    free(A_squared);


    printf("\n---------------------------\n");
    printf("__SUCCESS__\n");
    printf("---------------------------\n");
    printf("N                 = %d\n", N);
    printf("---------------------------\n\n");

    return 0;
}
